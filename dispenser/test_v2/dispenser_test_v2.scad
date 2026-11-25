// =====================================================================
//  타투 카트리지 디스펜서 - 테스트 v2 (기능 테스트 전용, 카드 1장)
//  프린터: Bambu Lab P2S / 필라멘트: PLA
//
//  테스트 목표: 카드 1장(5칸) 투입 → 아래로 내려옴 → 패들 누르면 1칸 컷팅 →
//              다음 칸이 내려와 대기
//  조절 기능:
//   · 칸 간격 조절  : 패들 옆 "간격 조절 핀" (24~36mm, 2mm 단위, 숫자 각인)
//   · 카드 폭 조절  : 오른쪽 "폭 가이드"를 들어서 톱니에 다시 걸기 (70~86mm, 2mm 단위)
//
//  part: "body" 본체 / "carrier" 패들+칼날판 / "tframe" 받침판+팔 /
//        "anvil" 커팅받침 / "guide" 폭 가이드 / "assembly" 조립 미리보기
// =====================================================================
part  = "assembly";
print = false;
press = 0;            // 미리보기: 1 = 패들 끝까지 누른 상태

/* ---------- [실측 치수] (2개 제품 기준, mm) ---------- */
card_w  = 80;    // A. 카드 가로
cell_p  = 29.8;  // B. 칸 간격 (G 절취선 간격과 같음)
bub_l   = 67;    // C. 볼록부 가로 길이
bub_w   = 15.5;  // D. 볼록부 세로 폭
bub_h   = 16;    // E. 볼록부 높이
card_t  = 0.5;   // F. 납작한 부분 두께
n_cells = 5;

/* ---------- [조절 범위] ---------- */
w_min = 70;  w_max = 86;     // 카드 폭 조절 범위
p_min = 24;  p_max = 36;     // 칸 간격 조절 범위
bub_h_max = 18;              // 대응 가능한 최대 볼록부 높이

/* ---------- [출력 공차 / 하드웨어] ---------- */
clr       = 0.35;
blade_t   = 0.5;   blade_w = 18;   blade_len = 88;   // 18mm 커터날, 88mm로 부러뜨림
fil_d     = 1.75;                                    // 핀 = 필라멘트

$fn = 36;

// =====================================================================
//  파생 치수
// =====================================================================
p_set  = p_max - 2*round((p_max - cell_p)/2);   // 핀 위치 (가장 가까운 2mm 단계)
w_set  = card_w;
card_h = n_cells*cell_p;

wall_o = 3;  chan = 6;  rib = 2;  g_t = 3;            // g_t = 폭 가이드 두께
slot_w = w_max + 1.6 + g_t + 0.8;
x_s0   = wall_o + chan + rib;
x_s1   = x_s0 + slot_w;
mw     = x_s1 + rib + chan + wall_o;
x_c0   = x_s0 + 0.8;                                  // 카드 왼쪽 끝 (고정)
lip_x1 = x_c0 + 4;

gap_z  = 90;                       // 칼날 높이 (고정)
z_pl0  = gap_z - 3;  z_pl1 = gap_z + 3;
function tt(p) = gap_z - p;        // 받침판 윗면 높이
tt_lo  = tt(p_max);  tt_hi = tt(p_min);
arm_h  = 22;
ch_bot = tt_lo - arm_h - 0.6;
z_lb   = z_pl1 + 6;                // 하부 박스 윗면
z_top  = gap_z + 3*cell_p;         // 매거진 윗면 (카드 윗부분은 위로 나옴)
z_anv  = gap_z + 6;                // 앤빌 윗면

y_a    = card_t + clr;
ov     = 6;
y_e0   = -bub_h_max - 1;
S      = (y_a + ov) - y_e0;        // 패들 스트로크
b_exp  = ov + y_a + 0.7;
tip0   = y_e0 - b_exp;
tp_len = 18;
tip_h  = 1.2;
t_tf   = y_e0 - 1.5;               // 받침판 앞끝
t_tr   = card_t;                   // 받침판 뒤끝
y_pk   = t_tr + S + 1.5;
y_fw1  = tip0 - 11;  y_fw0 = y_fw1 - 3;
t_pad  = y_fw0 - S;
y_sp   = y_fw0 + 22;   z_sp = 49;  // 멈춤핀
y_ins1 = y_pk + 10;
y_back = y_ins1 + 3;
y_bf   = -bub_h_max - 1.5;  y_uf = y_bf - 3;
y_bw1  = y_a + 4;                  // 매거진 뒤벽 두께
y_tray = t_pad - 5 - 30;

ch_k = (tt_lo - 6 - 6)/52;
function chz(y) = 6 + (y + 50)*ch_k;

// 간격 조절 핀 구멍 (패들 귀)
zA0  = gap_z - p_max - 6;
ycA  = t_pad + 6.5;  ycB = t_pad + 11.5;  ear_l = 18;
function tfz(p) = tt(p) - tt(p_set);      // 받침판 프레임 높이 변화

// 폭 가이드
function gx(w) = x_c0 + w + 0.4;          // 가이드 안쪽 면
rk_x0 = gx(w_set) - 2*floor((gx(w_set) - (gx(w_min)-2))/2);   // 톱니 시작 (위상 맞춤)
rk_x1 = mw - 1;

echo(str("모듈 크기 (폭x깊이x높이) = ", mw, " x ", y_back - y_tray, " x ", z_top+3));
echo(str("스트로크 = ", S, "  칸간격 핀 위치 = ", p_set, "mm"));

// =====================================================================
module box(x0,x1,y0,y1,z0,z1) { translate([x0,y0,z0]) cube([x1-x0, y1-y0, z1-z0]); }
module rbox(x0,x1,y0,y1,z0,z1,r=2) {
  hull() for (x=[x0+r,x1-r], y=[y0+r,y1-r]) translate([x,y,z0]) cylinder(r=r, h=z1-z0, $fn=20);
}
module mirror_x(m) { if (m==0) children(); else translate([mw,0,0]) mirror([1,0,0]) children(); }
module chute_solid(x0,x1) {
  translate([x0,0,0]) rotate([90,0,90]) linear_extrude(x1-x0)
    polygon([[y_tray-5,0],[10,0],[10,chz(10)],[-50,chz(-50)],[-50,3],[y_tray-5,3]]);
}
module rack(x0, x1, y0, y1, z) {   // 2mm 톱니 (위로)
  for (x=[x0:2:x1-2]) translate([x, y0, z]) rotate([-90,0,0]) linear_extrude(y1-y0)
    polygon([[0,0],[1,-1],[2,0]]);
}

// =====================================================================
//  본체 (한 덩어리)
// =====================================================================
module body() {
  difference() {
    union() {
      box(0, mw, y_fw0, y_back, 0, z_lb);                       // 하부 (커팅부)
      box(0, mw, y_uf, y_bw1, z_lb-0.01, z_top);                 // 매거진
      box(0, mw, y_tray, y_fw0+1, 0, 3);                         // 트레이
      box(0, mw, y_tray, y_tray+2.5, 0, 10);
      rack(rk_x0, rk_x1, y_uf, y_bf, z_top);                     // 폭 가이드 톱니 (앞)
      rack(rk_x0, rk_x1, y_a, y_bw1, z_top);                     // 폭 가이드 톱니 (뒤)
    }
    // 카드 + 낙하 공간
    difference() { box(x_s0, x_s1, y_fw1, y_a, 3, z_top+5); chute_solid(x_s0-1, x_s1+1); }
    box(x_s0, x_s1, y_bf, y_a, z_lb-1, z_top+5);
    difference() { box(x_s0, x_s1, y_fw0-1, y_fw1+1, 3, tt_lo-6); chute_solid(x_s0-1, x_s1+1); }
    // 매거진 앞 창
    box(lip_x1+2, x_s1-2, y_uf-1, y_bf+1, z_lb+6, z_top-8);
    // 앤빌 자리 / 받침판 이동 공간
    box(x_s0, x_s1, y_a-0.01, y_ins1, tt_hi+0.4, z_anv+0.01);
    box(x_s0-rib, x_s1+rib, y_a-0.01, y_pk, tt_lo-3-0.4, tt_hi+0.4);
    for (x=[x_s0-rib, x_s1]) box(x, x+rib, y_fw0-1, y_pk, tt_lo-3-0.4, tt_hi+0.5);
    // 팔 통로 + 복귀 스프링 자리
    for (x=[wall_o, x_s1+rib]) {
      box(x, x+chan, y_fw0-1, y_pk, ch_bot, z_pl1+0.5);
      box(x, x+chan, y_pk-0.01, y_pk+12, 45, 53);
    }
    // 칼날판 통로 (칸막이 위에 얹혀 미끄러짐)
    box(wall_o, mw-wall_o, y_fw0-1, 8, z_pl0-0.1, z_pl1+0.5);
    // 패들 귀가 들어오는 홈 (누를 때)
    for (x=[-1, mw-wall_o-clr]) box(x, x+wall_o+clr+1, y_fw0-1, y_fw0+ear_l+1, zA0-4.5, zA0+16.5);
    // 멈춤핀 구멍
    for (side=[0,1]) translate([side==0 ? -1 : mw-wall_o-chan-rib-1, y_sp, z_sp])
      rotate([0,90,0]) cylinder(d=fil_d+0.15, h=wall_o+chan+rib+1, $fn=16);
  }
  // 왼쪽 앞 립 (오른쪽 립은 폭 가이드에 붙어 있음)
  box(x_s0-0.01, lip_x1, -3, -clr, tt_hi+0.6, z_pl0-0.5);
  box(x_s0-0.01, lip_x1, y_bf-0.01, -clr, z_pl1+0.5, z_top);
}

// =====================================================================
//  캐리어: 패들 + 칼날판 + 간격 조절 귀
// =====================================================================
module carrier() {
  difference() {
    union() {
      rbox(0.5, mw-0.5, t_pad-5, t_pad, tt_lo-25, gap_z+20, 2);
      translate([wall_o+clr, 0, 0]) rotate([90,0,90]) linear_extrude(mw-2*wall_o-2*clr)
        polygon([[t_pad-0.1, z_pl0], [tip0-tp_len, z_pl0], [tip0, gap_z-tip_h],
                 [tip0, gap_z+tip_h], [tip0-tp_len, z_pl1], [t_pad-0.1, z_pl1]]);
      for (m=[0,1]) mirror_x(m) box(0.4, wall_o+clr-0.3, t_pad-0.1, t_pad+ear_l, zA0-4, zA0+16);
    }
    // 칼날 홈
    translate([wall_o-1, tip0-blade_w+b_exp-0.5, gap_z-(blade_t+0.2)/2]) cube([mw-2*wall_o+2, blade_w-b_exp+0.6, blade_t+0.2]);
    // 간격 조절 핀 구멍 + 숫자 각인
    for (m=[0,1]) mirror_x(m) {
      for (k=[0:3]) translate([-1, ycA, zA0+4*k]) rotate([0,90,0]) cylinder(d=fil_d+0.15, h=6, $fn=16);
      for (k=[0:2]) translate([-1, ycB, zA0+2+4*k]) rotate([0,90,0]) cylinder(d=fil_d+0.15, h=6, $fn=16);
    }
    for (k=[0:6]) {       // 숫자 각인 (바깥쪽 면, 칸 간격 mm)
      p = p_max - 2*k;  colA = (k%2==0);
      for (m=[0,1]) mirror_x(m)
        translate([0.4-0.6, colA ? ycA-1.9 : ycB+1.9, zA0 + 2*k])
          multmatrix([[0,0,1,0],[-1,0,0,0],[0,1,0,0],[0,0,0,1]])
            linear_extrude(1.6) text(str(p), size=2.6, halign=colA ? "left" : "right", valign="center", font="Liberation Sans:style=Bold");
    }
  }
}

// =====================================================================
//  받침판 프레임: 받침판 + 양쪽 팔 (패들 귀에 핀으로 연결, 높이 = 칸 간격)
// =====================================================================
module tframe() {
  t = tt(p_set);
  difference() {
    union() {
      box(wall_o+clr, mw-wall_o-clr, t_tf, t_tr, t-3, t);                       // 받침판
      for (x=[wall_o+clr, x_s1+rib+clr]) box(x, x+chan-2*clr, t_pad+0.5, t_tr, t-arm_h, t);  // 팔
    }
    for (x=[wall_o-1, x_s1+rib-1]) {
      // 간격 조절 핀 구멍
      for (yc=[ycA, ycB]) translate([x, yc, t-6]) rotate([0,90,0]) cylinder(d=fil_d+0.15, h=chan+2, $fn=16);
      // 멈춤핀 긴 홈 (조절 범위만큼 세로로 김)
      translate([x, y_sp-0.975-S-0.6, t-arm_h+4]) cube([chan+2, S+0.6+2*0.975, 14]);
    }
  }
}

module anvil() {
  difference() {
    box(x_s0+clr, x_s1-clr, y_a, y_ins1-clr, tt_hi+0.4+0.15, z_anv);
    box(x_s0, x_s1, y_a-1, y_a+ov+2, gap_z-0.5, gap_z+0.5);
  }
}

// =====================================================================
//  폭 가이드 (오른쪽 벽 + 오른쪽 립, 위 톱니에 걸림)
// =====================================================================
module guide(w=w_set) {
  g = gx(w);
  difference() {
    union() {
      box(g, g+g_t, y_bf+clr, y_a-clr, z_pl1+1.5, z_top+0.01);              // 세로판
      box(g-4, g+0.01, -3, -clr-0.1, z_pl1+1.5, z_top+0.01);                 // 립
      box(g, g+9, y_uf, y_bw1, z_top+0.5, z_top+4);                          // 윗 손잡이 (톱니에 얹힘)
    }
    // 아래 톱니 홈 (본체 톱니와 맞물림)
    for (yy=[[y_uf-1, y_bf+0.01], [y_a-0.01, y_bw1+1]])
      for (x=[rk_x0:2:rk_x1]) translate([x, yy[0], z_top+0.5]) rotate([-90,0,0]) linear_extrude(yy[1]-yy[0])
        polygon([[-0.2,0.01],[1,-1.15],[2.2,0.01]]);
  }
}

// =====================================================================
module card_preview() {
  for (k=[0:n_cells-1]) translate([x_c0, 0, tt(p_set) + k*cell_p]) {
    cube([card_w, card_t, cell_p-0.4]);
    translate([(card_w-bub_l)/2, -bub_h, (cell_p-bub_w)/2]) cube([bub_l, bub_h, bub_w]);
  }
}
module blade() translate([x_c0-1, tip0-blade_w+b_exp, gap_z-blade_t/2]) cube([blade_len, blade_w, blade_t]);

if (part=="assembly") {
  s = press ? S : 0;
  color("#2b2b30") body();
  translate([0,s,0]) { color("#ff7a1a") carrier(); color("#ffc890") tframe(); color("silver") blade(); }
  color("#4f86c6") anvil();
  color("#7a8fb0") guide();
  color([0.75,0.88,1.0]) card_preview();
}
else if (part=="body")    body();
else if (part=="carrier") { if (print) rotate([90,0,0]) translate([0,-(t_pad-5),0]) carrier(); else carrier(); }
else if (part=="tframe")  { if (print) translate([0,0,tt(p_set)]) mirror([0,0,1]) tframe(); else tframe(); }
else if (part=="anvil")   { if (print) rotate([-90,0,0]) translate([0,-y_ins1+clr,0]) anvil(); else anvil(); }
else if (part=="guide")   { if (print) translate([0,0,z_top+4]) mirror([0,0,1]) guide(); else guide(); }
