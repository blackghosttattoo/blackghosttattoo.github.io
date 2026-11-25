// =====================================================================
//  타투 카트리지 디스펜서 - 1단계 테스트 (커팅 유닛 + 카드 1장 홀더)
//  프린터: Bambu Lab P2S / PLA / 서포트 없이 출력되게 설계
//
//  1단계: 카드 1장(5칸) → 패들 누르면 맨 아래 칸 컷팅 → 다음 칸 내려와 대기
//  2단계: "holder1" 대신 4장 매거진을 같은 결합 핀에 꽂음 (커팅 유닛 재사용)
//  3단계: 폭 가이드 + 옆 모듈 연결 (옆판 아래 연결 구멍 미리 있음)
//
//  part: "body" 커팅 유닛 / "carrier" 패들+칼날판 / "tframe" 받침판+팔 /
//        "anvil" 커팅받침 바 / "holder1" 카드 1장 홀더 / "assembly"
// =====================================================================
part  = "assembly";
print = false;
press = 0;

/* ---------- [실측 치수] (2개 제품 기준, mm) ---------- */
card_w  = 80;    // A
cell_p  = 29.8;  // B (= G 절취선 간격)
bub_l   = 67;    // C
bub_w   = 15.5;  // D
bub_h   = 16;    // E
card_t  = 0.5;   // F
n_cells = 5;

/* ---------- [조절 범위] ---------- */
w_min = 70;  w_max = 86;
p_min = 24;  p_max = 36;
bub_h_max = 18;

/* ---------- [공차 / 하드웨어] ---------- */
clr     = 0.35;
blade_t = 0.5;  blade_w = 18;  blade_len = 88;
fil_d   = 1.75;
$fn = 32;

// =====================================================================
p_set  = p_max - 2*round((p_max - cell_p)/2);
card_h = n_cells*cell_p;

wall_o = 3;  chan = 4.5;  g_t = 2.5;
arm_t  = chan - 2*clr;
slot_w = w_max + 1.6 + g_t + 0.8;      // 3단계 폭 가이드 자리까지 포함
x_s0   = wall_o + chan;
x_s1   = x_s0 + slot_w;
mw     = x_s1 + chan + wall_o;
x_c0   = x_s0 + 0.8;
lip_x1 = x_c0 + 4;

gap_z  = 70;
ph     = 2;                              // 칼날판 반두께
z_pl0  = gap_z - ph;  z_pl1 = gap_z + ph;
function tt(p) = gap_z - p;
tt_lo  = tt(p_max);  tt_hi = tt(p_min);
arm_h  = 22;
z_cu   = z_pl1 + 11;                     // 커팅 유닛 윗면
H1     = 55;                             // 홀더 높이

y_a    = card_t + clr;
ov     = 4;
y_e0   = -bub_h_max - 1;
S      = (y_a + ov) - y_e0;
b_exp  = ov + y_a + 0.7;
tip0   = y_e0 - b_exp;
tp_len = 18;  tip_h = 1.0;
t_tf   = y_e0 - 1.5;  t_tr = card_t;
y_pk   = t_tr + S + 1.5;
y_fw0  = tip0 - 14;
t_pad  = y_fw0 - S;
y_sp   = y_fw0 + 22;  z_sp = 30;
y_sb   = y_pk + 12;                      // 옆판 뒤끝
y_an1  = y_a + 10;                       // 앤빌 뒤끝
y_bf   = -bub_h_max - 1.5;  y_uf = y_bf - 3;
zs     = (tt_lo - arm_h + tt_hi)/2;      // 복귀 스프링 높이

zA0  = gap_z - p_max - 6;
ycA  = t_pad + 6.5;  ycB = t_pad + 11.5;  ear_l = 18;
function tfz(p) = tt(p) - tt(p_set);

mounts = [[(wall_o+chan)/2, y_fw0+5], [(wall_o+chan)/2, y_sb-5],
          [mw-(wall_o+chan)/2, y_fw0+5], [mw-(wall_o+chan)/2, y_sb-5]];

echo(str("커팅 유닛 = ", mw, " x ", y_sb - y_fw0, " x ", z_cu, " (패들 포함 깊이 ", y_sb-(t_pad-3), ")"));
echo(str("스트로크 = ", S, "  간격 핀 = ", p_set));

// =====================================================================
module box(x0,x1,y0,y1,z0,z1) { translate([x0,y0,z0]) cube([x1-x0, y1-y0, z1-z0]); }
module rbox(x0,x1,y0,y1,z0,z1,r=2) {
  hull() for (x=[x0+r,x1-r], y=[y0+r,y1-r]) translate([x,y,z0]) cylinder(r=r, h=z1-z0, $fn=16);
}
module mirror_x(m) { if (m==0) children(); else translate([mw,0,0]) mirror([1,0,0]) children(); }
// 옆판 안쪽 면에 붙는 턱 (아래 45도 경사 → 서포트 불필요)
module ledge(y0,y1,ztop,w) {
  translate([0,y1,0]) rotate([90,0,0]) linear_extrude(y1-y0)
    polygon([[wall_o-0.01,ztop],[wall_o+w,ztop],[wall_o+w,ztop-0.8],[wall_o-0.01,ztop-0.8-w-0.01]]);
}
// 위가 뾰족한 창 (브릿지 없음)
module gwin(y0,y1,z0,z1) {
  h = (y1-y0)/2;
  translate([-1,0,0]) rotate([90,0,90]) linear_extrude(wall_o+2)
    polygon([[y0,z0],[y1,z0],[y1,max(z0,z1-h)],[(y0+y1)/2,z1],[y0,max(z0,z1-h)]]);
}

// =====================================================================
//  커팅 유닛 본체
// =====================================================================
module body() {
  for (m=[0,1]) mirror_x(m) {
    difference() {
      union() {
        box(0, wall_o, y_fw0, y_sb, 0, z_cu);                       // 옆판
        ledge(y_fw0, -1, z_pl0-0.1, 2.5);                            // 칼날판 턱
        ledge(y_a, y_an1, gap_z-6, 2);                               // 앤빌 받침 턱
        box(wall_o-0.01, wall_o+2, y_an1+clr, y_an1+2.5, gap_z-6-2.8, gap_z+6);   // 앤빌 뒤 멈춤
        // 복귀 스프링 받침 (아래 경사) + 핀
        translate([0, y_pk+11, 0]) rotate([90,0,0]) linear_extrude(4)
          polygon([[wall_o-0.01,zs+4],[wall_o+chan,zs+4],[wall_o+chan,zs-4],[wall_o-0.01,zs-4-chan]]);
        translate([wall_o+chan/2, y_pk+7.01, zs]) rotate([90,0,0]) cylinder(d=2.6, h=7, $fn=16);
        // 위 결합 블록 (아래 경사) + 핀
        for (yy=[y_fw0+1, y_sb-9]) translate([0, yy+8, 0]) rotate([90,0,0]) linear_extrude(8)
          polygon([[wall_o-0.01,z_cu],[wall_o+chan,z_cu],[wall_o+chan,z_cu-5],[wall_o-0.01,z_cu-5-chan]]);
        for (yy=[y_fw0+5, y_sb-5]) translate([(wall_o+chan)/2, yy, z_cu-0.01]) cylinder(d=3, h=4, $fn=20);
      }
      gwin(y_sp+4, y_pk-2, 8, gap_z-14);                             // 창
      gwin(y_fw0+6, y_sp-4, 8, zA0-6);
      // 패들 귀 홈 (위 뾰족)
      translate([-1,0,0]) rotate([90,0,90]) linear_extrude(wall_o+clr+1.01)
        polygon([[y_fw0-1,zA0-4.5],[y_fw0+ear_l+1,zA0-4.5],[y_fw0+ear_l+1,zA0+16.5],[y_fw0+(ear_l)/2,zA0+16.5+ear_l/2+1],[y_fw0-1,zA0+16.5]]);
      translate([-1, y_sp, z_sp]) rotate([0,90,0]) cylinder(d=fil_d+0.15, h=wall_o+2, $fn=16);   // 멈춤핀
      for (yy=[y_fw0+3, y_sb-3]) translate([-1, yy, 14]) rotate([0,90,0]) cylinder(d=3.3, h=wall_o+2, $fn=20); // 3단계 연결
    }
  }
  box(0, mw, y_fw0, y_fw0+5, 0, 4);       // 아래 연결대 앞
  box(0, mw, y_sb-5, y_sb, 0, 4);         // 아래 연결대 뒤
}

// =====================================================================
//  캐리어 (패들 + 칼날판 + 간격 조절 귀)
// =====================================================================
module carrier() {
  difference() {
    union() {
      rbox(0.5, mw-0.5, t_pad-3, t_pad, zA0-6, gap_z+8, 1.4);
      translate([wall_o+clr, 0, 0]) rotate([90,0,90]) linear_extrude(mw-2*wall_o-2*clr)
        polygon([[t_pad-0.1, z_pl0], [tip0-tp_len, z_pl0], [tip0, gap_z-tip_h],
                 [tip0, gap_z+tip_h], [tip0-tp_len, z_pl1], [t_pad-0.1, z_pl1]]);
      for (m=[0,1]) mirror_x(m) box(0.6, wall_o+clr-0.3, t_pad-0.1, t_pad+ear_l, zA0-4, zA0+16);
    }
    box(16, mw-16, t_pad-4, t_pad+1, zA0+20, z_pl0-3);                    // 패들 창
    for (x=[x_s0+10:12:x_s1-18]) box(x, x+8, t_pad+3, tip0-tp_len-3, z_pl0-1, z_pl1+1);   // 칼날판 창 (좁게 여러 개)
    translate([wall_o-1, tip0-blade_w+b_exp-0.5, gap_z-(blade_t+0.2)/2]) cube([mw-2*wall_o+2, blade_w-b_exp+0.6, blade_t+0.2]);
    for (m=[0,1]) mirror_x(m) {
      for (k=[0:3]) translate([-1, ycA, zA0+4*k]) rotate([0,90,0]) cylinder(d=fil_d+0.15, h=6, $fn=16);
      for (k=[0:2]) translate([-1, ycB, zA0+2+4*k]) rotate([0,90,0]) cylinder(d=fil_d+0.15, h=6, $fn=16);
    }
    for (k=[0:6]) {
      p = p_max - 2*k;  colA = (k%2==0);
      for (m=[0,1]) mirror_x(m)
        translate([0.4-0.6, colA ? ycA-1.9 : ycB+1.9, zA0 + 2*k])
          multmatrix([[0,0,1,0],[-1,0,0,0],[0,1,0,0],[0,0,0,1]])
            linear_extrude(1.6) text(str(p), size=2.6, halign=colA ? "left" : "right", valign="center", font="Liberation Sans:style=Bold");
    }
  }
}

// =====================================================================
//  받침판 프레임 (받침판 + 양쪽 팔)
// =====================================================================
module tframe() {
  t = tt(p_set);
  difference() {
    union() {
      box(wall_o+clr, mw-wall_o-clr, t_tf, t_tr, t-3, t);
      for (x=[wall_o+clr, x_s1+clr]) box(x, x+arm_t, t_pad+0.5, t_tr, t-arm_h, t);
    }
    for (x=[wall_o-1, x_s1-1]) {
      for (yc=[ycA, ycB]) translate([x, yc, t-6]) rotate([0,90,0]) cylinder(d=fil_d+0.15, h=chan+2, $fn=16);
      translate([x, y_sp-0.975-S-0.6, t-arm_h+4.5]) cube([chan+2, S+0.6+2*0.975, 15]);
    }
    // 팔 가운데 덜어내기
    for (x=[wall_o-1, x_s1-1]) {
      l = (y_sp-0.975-S-0.6-3)-(t_pad+ear_l+4);
      translate([x, t_pad+ear_l+4, t-arm_h/2]) rotate([0,90,0]) linear_extrude(chan+2)
        polygon([[-(arm_h-10)/2,0],[0,-min(l/2,(arm_h-10)/2)],[(arm_h-10)/2,0],[(arm_h-10)/2,0]]);
    }
  }
}

// 커팅 받침 바 (앞면 홈에 칼날이 들어감)
module anvil() {
  difference() {
    box(wall_o+clr, mw-wall_o-clr, y_a, y_an1, gap_z-6+0.15, gap_z+6);
    box(0, mw, y_a-1, y_a+ov+2, gap_z-0.5, gap_z+0.5);
  }
}

// =====================================================================
//  카드 1장 홀더 (1단계용, 커팅 유닛 위 핀에 꽂음)
// =====================================================================
module holder1() {
  translate([0,0,z_cu]) difference() {
    union() {
      for (m=[0,1]) mirror_x(m) box(0, wall_o+chan, y_fw0+1, y_sb-1, 0, 3);    // 옆 띠 (옆판 위)
      box(0, mw, y_uf, y_bf, 0, 3);                                            // 앞 띠 (볼록부 앞)
      box(0, mw, y_a, y_a+3, 0, 3);                                            // 뒤 띠
      // 왼쪽 기둥 (앞 립 + 카드 왼쪽 기준)
      box(0, lip_x1, -3, -clr, 0, H1);
      box(0, x_c0-0.4, -3, y_a+3, 0, H1);
      box(0, wall_o+chan, y_uf, -3, 0, 8);
      // 오른쪽 기둥 (1단계는 카드 폭 고정)
      box(x_c0+card_w-4, mw, -3, -clr, 0, H1);
      box(x_c0+card_w+0.4, mw, -3, y_a+3, 0, H1);
      box(mw-wall_o-chan, mw, y_uf, -3, 0, 8);
      // 뒤 받침 (카드 뒷면)
      box(mw/2-12, mw/2+12, y_a, y_a+2.5, 0, H1);
    }
    for (p=mounts) translate([p[0], p[1], -0.01]) cylinder(d=3+2*clr, h=4.5, $fn=20);
  }
}

module card_preview() {
  for (k=[0:n_cells-1]) translate([x_c0, 0, tt(p_set) + k*cell_p]) {
    cube([card_w, card_t, cell_p-0.4]);
    translate([(card_w-bub_l)/2, -bub_h, (cell_p-bub_w)/2]) cube([bub_l, bub_h, bub_w]);
  }
}
module blade() translate([x_c0-1, tip0-blade_w+b_exp, gap_z-blade_t/2]) cube([blade_len, blade_w, blade_t]);

// =====================================================================
if (part=="assembly") {
  s = press ? S : 0;
  color("#2b2b30") body();
  translate([0,s,0]) { color("#ff7a1a") carrier(); color("#ffc890") tframe(); color("silver") blade(); }
  color("#4f86c6") anvil();
  color("#6a7a96") holder1();
  color([0.75,0.88,1.0]) card_preview();
}
else if (part=="body")    body();
else if (part=="carrier") { if (print) rotate([90,0,0]) translate([0,-(t_pad-3),0]) carrier(); else carrier(); }
else if (part=="tframe")  { if (print) translate([0,0,tt(p_set)]) mirror([0,0,1]) tframe(); else tframe(); }
else if (part=="anvil")   { if (print) rotate([-90,0,0]) translate([0,-y_an1,0]) anvil(); else anvil(); }
else if (part=="holder1") { if (print) translate([0,0,-z_cu]) holder1(); else holder1(); }
