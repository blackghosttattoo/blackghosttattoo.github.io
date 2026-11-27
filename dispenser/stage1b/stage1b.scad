// =====================================================================
// ※ 이전 시안 (톱니 조절 방식) — 더 이상 사용 안 함. 테스트는 stage1b_test.scad 사용
//  타투 카트리지 디스펜서 - 1단계 개선판 (stage1b)
//  P2S / PLA / 서포트 없이 출력되게 설계
//
//  변경점 (1단계 테스트 피드백 반영)
//   · 볼록부 16mm 기준 → 누르는 거리 단축
//   · 칼날 3° 비스듬히 (작두식, 한쪽부터 잘림), 칼날 90mm > 카드 80mm
//   · 덮개(후드) : 패들이 덮개 안에서만 움직임
//   · 스프링 4개 : 암(겉기둥, 본체) + 수(속기둥, 별도) / ㄱ자 홈 + 긴 홈 + 잠김 홈
//                  → 끼우고 돌리면 잠김, 손 떼면 앞 벽에 걸림(멈춤 턱)
//   · 톱니 조절 : 왼쪽 손잡이 → 축 → 톱니바퀴 2개 → 받침판 팔 톱니(랙)
//                  딸깍 휠(24칸) : 한 칸 ≈ 1mm, 24~36mm
//
//  part: body / carrier / tframe / anvil / holder1 / hoodtop /
//        rod(×4) / shaft / pinion(×2) / dwheel / knob /
//        zspring(×4, 대체 스프링) / dblade(대체 칼날) / assembly / section
// =====================================================================
part  = "assembly";
print = false;
press = 0;

/* ---------- [실측 치수] ---------- */
card_w  = 80;  cell_p = 29.8;  bub_l = 67;  bub_w = 15.5;  bub_h = 16;  card_t = 0.5;
n_cells = 5;

/* ---------- [설계 기준] ---------- */
bub_h_max = 16;               // 볼록부 16mm 기준
p_min = 24;  p_max = 36;
w_max = 86;

/* ---------- [칼날] ---------- */
b_ang   = 3;                  // 작두 각도
blade_t = 0.5;  blade_w = 18;  blade_len = 90;
e_t     = 3.5;                // 칼날 뒤쪽(늦게 닿는 쪽) 노출

clr = 0.35;
$fn = 32;

// =====================================================================
card_h = n_cells*cell_p;
wall_o = 3;  chan = 4.5;  g_t = 2.5;
arm_t  = chan - 2*clr;
slot_w = w_max + 1.6 + g_t + 0.8;
x_s0   = wall_o + chan;
x_s1   = x_s0 + slot_w;
mw     = x_s1 + chan + wall_o;
x_c0   = x_s0 + 0.8;
lip_x1 = x_c0 + 4;

gap_z  = 70;  ph = 2;
z_pl0  = gap_z - ph;  z_pl1 = gap_z + ph;
function tt(p) = gap_z - p;
tt_lo  = tt(p_max);  tt_hi = tt(p_min);
p_set  = round(cell_p);                       // 기본 위치 (30)
z_cu   = z_pl1 + 11;
H1     = 55;

y_a    = card_t + clr;
dy_b   = blade_len*sin(b_ang);
y_ld0  = -bub_h_max - 1;                      // 앞서 닿는 칼날 끝 (대기)
y_t0   = y_ld0 - dy_b;                        // 늦게 닿는 칼날 끝 (대기)
S      = (y_a + 1.5) - y_t0;                  // 누르는 거리
tip0   = y_t0 - e_t;
tp_len = 18;  tip_h = 1.0;
x_bl   = x_c0 - 5;                            // 칼날 왼쪽 끝 x
t_tf   = y_t0 - 1.5;  t_tr = card_t;
y_fw0  = tip0 - 14;
t_pad  = y_fw0 - S;
y_an1  = y_a + 13;                            // 앤빌 뒤끝
g_dep  = 1.5 + dy_b + 2;                      // 앤빌 홈 깊이
y_sb   = t_tr + S + 3;                        // 옆판 뒤끝
y_bf   = -bub_h_max - 1.5;  y_uf = y_bf - 3;

// ---- 스프링 기둥 (옆판 바깥) ----
sp_x   = -5.5;  sp_zs = [36.5, 78];  sp_od = 11;  sp_id = 7.2;  sp_len = 60;
sl_w   = 2.4;                                 // 홈 폭
nub_d  = 2.0;
y_nub0 = y_fw0 + 2.8;                         // 손 뗐을 때 돌기 중심 (잠김 홈)
rod_d  = 6.6;  rod_end0 = y_nub0 + 2.5;      // 속기둥 뒤끝 (대기)
peg    = 4;                                   // 패들 네모 구멍

// ---- 톱니 조절 ----
gm = 1;  gn = 8;  gr = gm*gn/2;               // 피니언 (8잇수, 모듈1)
gz = 24;  gy = t_pad + 9;
arm_h = 29.5;
shaft_af = 4;
n_click = 24;
hood_x0 = -15;  hood_t = 3.8;
z_hood = z_cu + 3;

echo(str("누르는 거리 S = ", S, " mm / 패들 앞면 돌출(덮개 깊이) = ", y_fw0-(t_pad-3), " mm"));
echo(str("본체 폭(덮개 포함) = ", mw - 2*hood_x0, "  깊이(덮개 포함) = ", y_sb - (t_pad-4)));
echo(str("딸깍 1칸 = ", PI*gm*gn/n_click, " mm"));

// =====================================================================
module box(x0,x1,y0,y1,z0,z1) { translate([x0,y0,z0]) cube([x1-x0, y1-y0, z1-z0]); }
module rbox(x0,x1,y0,y1,z0,z1,r=2) {
  hull() for (x=[x0+r,x1-r], y=[y0+r,y1-r]) translate([x,y,z0]) cylinder(r=r, h=z1-z0, $fn=16);
}
module mirror_x(m) { if (m==0) children(); else translate([mw,0,0]) mirror([1,0,0]) children(); }
module ledge(y0,y1,ztop,w) {
  translate([0,y1,0]) rotate([90,0,0]) linear_extrude(y1-y0)
    polygon([[wall_o-0.01,ztop],[wall_o+w,ztop],[wall_o+w,ztop-0.8],[wall_o-0.01,ztop-0.8-w-0.01]]);
}
module gwin(y0,y1,z0,z1) {
  h = (y1-y0)/2;
  translate([-1,0,0]) rotate([90,0,90]) linear_extrude(wall_o+2)
    polygon([[y0,z0],[y1,z0],[y1,max(z0,z1-h)],[(y0+y1)/2,z1],[y0,max(z0,z1-h)]]);
}
module ycyl(d, y0, y1, fn=32) translate([0,y0,0]) rotate([-90,0,0]) cylinder(d=d, h=y1-y0, $fn=fn);
module gear2d(n, m) {
  r = n*m/2;
  union() { circle(r - 1.25*m, $fn=40);
    for (i=[0:n-1]) rotate(i*360/n) polygon([[r-1.3*m,-0.75*m],[r+m,-0.38*m],[r+m,0.38*m],[r-1.3*m,0.75*m]]); }
}
module hex2d(af) circle(d=af/cos(30), $fn=6);

// =====================================================================
//  스프링 겉기둥 (암) - 옆판 바깥, 위/아래 2개 (왼쪽 기준, mirror로 오른쪽)
// =====================================================================
module bayonet_cut(zc) {
  // A 입구 홈 (위쪽), B 돌리는 홈 (위→바깥 90°), C 긴 홈 (바깥쪽, 맨 앞 1mm는 잠김 홈)
  translate([sp_x, 0, zc]) {
    box(-sl_w/2, sl_w/2, y_fw0-1, y_fw0+5.2, 0, sp_od);                           // A
    intersection() {                                                               // B
      translate([0, y_fw0+2.8-sl_w/2+1, 0]) rotate([-90,0,0]) cylinder(d=sp_od+2, h=5.2-(2.8-sl_w/2+1), $fn=40);
      box(-sp_od, sl_w/2, y_fw0-1, y_fw0+10, -sl_w/2, sp_od);
    }
    box(-sp_od, 0, y_nub0-sl_w/2, y_nub0 + S + sl_w/2 + 0.5, -sl_w/2, sl_w/2);   // C (+잠김 홈)
  }
}
module sleeves() {
  difference() {
    union() {
      for (zc=sp_zs) translate([sp_x,0,zc]) ycyl(sp_od, y_fw0, y_fw0+sp_len, 40);
      for (zc=sp_zs) box(sp_x, 0.01, y_fw0, y_fw0+sp_len, zc-1.5, zc+1.5);       // 옆판과 연결
      box(sp_x-1, sp_x+1, y_fw0, y_fw0+sp_len, 0, sp_zs[1]);                    // 세로 받침 (바닥~위 기둥)
      // 덮개 벽 연결부
      box(hood_x0+hood_t-0.01, sp_x-1, y_fw0, y_fw0+8, 0, z_hood);
    }
    for (zc=sp_zs) translate([sp_x,0,zc]) ycyl(sp_id, y_fw0-1, y_fw0+sp_len-2, 40);
    for (zc=sp_zs) bayonet_cut(zc);
    // 축/손잡이가 지나가는 홈
    box(hood_x0-1, 0.5, y_fw0-1, gy+S+3.5, gz-3.2, gz+3.2);
  }
}
// 덮개 벽 (왼쪽 기준)
module hood_wall(slot=true) {
  difference() {
    box(hood_x0, hood_x0+hood_t, t_pad-4, y_fw0+8, 0, z_hood);
    if (slot) box(hood_x0-1, hood_x0+hood_t+1, gy-3.5, gy+S+3.5, gz-3.2, gz+3.2);
    for (yy=[t_pad, y_fw0+4]) translate([hood_x0+hood_t/2, yy, z_hood-4]) cylinder(d=2.9, h=5, $fn=16);
  }
}

// =====================================================================
//  본체 (커팅 유닛)
// =====================================================================
module body() {
  for (m=[0,1]) mirror_x(m) {
    difference() {
      union() {
        box(0, wall_o, y_fw0, y_sb, 0, z_cu);
        ledge(y_fw0, -1, z_pl0-0.1, 2.5);
        ledge(y_a, y_an1, gap_z-6, 2);
        box(wall_o-0.01, wall_o+2, y_an1+clr, y_an1+2.5, gap_z-6-2.8, gap_z+6);
        for (yy=[y_fw0+1, y_sb-9]) translate([0, yy+8, 0]) rotate([90,0,0]) linear_extrude(8)
          polygon([[wall_o-0.01,z_cu],[wall_o+chan,z_cu],[wall_o+chan,z_cu-5],[wall_o-0.01,z_cu-5-chan]]);
        for (yy=[y_fw0+5, y_sb-5]) translate([(wall_o+chan)/2, yy, z_cu-0.01]) cylinder(d=3, h=4, $fn=20);
      }
      gwin(y_fw0+20, y_sb-5, 6, gap_z-14);
      // 귀 + 축 + 딸깍 휠이 들어오는 홈 (누를 때)
      translate([-1,0,0]) rotate([90,0,90]) linear_extrude(wall_o+clr+1.01)
        polygon([[y_fw0-1,gz-10.5],[y_fw0+(gy+7-t_pad)+1,gz-10.5],[y_fw0+(gy+7-t_pad)+1,gz+7],
                 [y_fw0+(gy+7-t_pad)/2,gz+7+(gy+7-t_pad)/2],[y_fw0-1,gz+7]]);
      for (yy=[y_fw0+3, y_sb-3]) translate([-1, yy, 14]) rotate([0,90,0]) cylinder(d=3.3, h=wall_o+2, $fn=20);
    }
    sleeves();
    hood_wall(m==0);
  }
  box(0, mw, y_fw0, y_fw0+5, 0, 4);
  box(0, mw, y_sb-5, y_sb, 0, 4);
}

// =====================================================================
//  캐리어 (패들 + 비스듬한 칼날판 + 귀 + 딸깍 걸쇠)
// =====================================================================
module blade_slot() {   // 칼날 꽂는 홈 (칼날 각도대로)
  translate([x_bl, y_t0, gap_z]) rotate([0,0,b_ang])
    translate([-1, -(blade_w+0.3), -(blade_t+0.2)/2]) cube([blade_len+2, blade_w+0.3+12, blade_t+0.2]);
}
module carrier() {
  difference() {
    union() {
      rbox(hood_x0+hood_t+0.4, mw-hood_x0-hood_t-0.4, t_pad-3, t_pad, 26, sp_zs[1]+6, 1.4);
      translate([wall_o+clr, 0, 0]) rotate([90,0,90]) linear_extrude(mw-2*wall_o-2*clr)
        polygon([[t_pad-0.1, z_pl0], [tip0-tp_len, z_pl0], [tip0, gap_z-tip_h],
                 [tip0, gap_z+tip_h], [tip0-tp_len, z_pl1], [t_pad-0.1, z_pl1]]);
      for (m=[0,1]) mirror_x(m) box(0.6, wall_o+clr-0.3, t_pad-0.1, gy+7, gz-6, 30);   // 귀 (축 받침)
      // 딸깍 걸쇠 (왼쪽): 패들 뒤에서 뻗은 얇은 판, 휠 아래에서 위로 눌러줌
      box(-2.8, 3.05, t_pad-0.1, t_pad+2, gz-7.6, gz-6+0.01);
      box(-2.8, 0.2, t_pad+1.9, gy+1.5, gz-7.6, gz-6.4);
      translate([-2.8, gy, gz-6.4-0.01]) rotate([0,90,0]) linear_extrude(3) polygon([[0,-0.7],[-0.9,0],[0,0.7]]);
    }
    box(18, mw-18, t_pad-4, t_pad+1, 34, z_pl0-3);                                     // 패들 창
    for (x=[x_s0+10:12:x_s1-18]) box(x, x+8, t_pad+3, tip0-tp_len-3, z_pl0-1, z_pl1+1);
    blade_slot();
    for (m=[0,1]) mirror_x(m) translate([-1, gy, gz]) rotate([0,90,0]) cylinder(d=shaft_af/cos(30)+0.6, h=6, $fn=24);
    for (m=[0,1]) mirror_x(m) for (zc=sp_zs) translate([sp_x-(peg+0.3)/2, t_pad-4, zc-(peg+0.3)/2]) cube([peg+0.3, 5, peg+0.3]);
  }
}

// =====================================================================
//  받침판 프레임 (받침판 + 팔 + 팔의 세로 홈 톱니)
// =====================================================================
module tframe() {
  t = tt(p_set);
  difference() {
    union() {
      box(wall_o+clr, mw-wall_o-clr, t_tf, t_tr, t-3, t);
      for (x=[wall_o+clr, x_s1+clr]) box(x, x+arm_t, gy-gr-2.3-2, t_tr, t-arm_h, t);
    }
    // 세로 홈: 앞쪽 매끈한 벽 / 뒤쪽 벽에 톱니 (피니언이 물림)
    for (x=[wall_o-1, x_s1-1]) box(x, x+chan+2, gy-gr-1.3, gy+gr+1.3, t-arm_h+2, t-4.5);
  }
  // 랙 톱니 (홈 뒤쪽 벽)
  for (x=[wall_o+clr, x_s1+clr]) for (k=[0:8]) {
    zc = t - arm_h + 3.2 + k*PI*gm;
    if (zc < t-5.5) translate([x, gy+gr+1.3, zc]) rotate([0,90,0]) linear_extrude(arm_t)
      polygon([[-0.75*gm,0.01],[0.75*gm,0.01],[0.38*gm,-2.25*gm],[-0.38*gm,-2.25*gm]]);
  }
}
function tfz(p) = tt(p) - tt(p_set);

module anvil() {
  difference() {
    box(wall_o+clr, mw-wall_o-clr, y_a, y_an1, gap_z-6+0.15, gap_z+6);
    box(0, mw, y_a-1, y_a+g_dep, gap_z-0.5, gap_z+0.5);
  }
}

module holder1() {
  mounts = [[(wall_o+chan)/2, y_fw0+5], [(wall_o+chan)/2, y_sb-5],
            [mw-(wall_o+chan)/2, y_fw0+5], [mw-(wall_o+chan)/2, y_sb-5]];
  translate([0,0,z_cu]) difference() {
    union() {
      for (m=[0,1]) mirror_x(m) box(0, wall_o+chan, y_fw0+1, y_sb-1, 0, 3);
      box(0, mw, y_uf, y_bf, 0, 3);
      box(0, mw, y_a, y_a+3, 0, 3);
      box(0, lip_x1, -3, -clr, 0, H1);
      box(0, x_c0-0.4, -3, y_a+3, 0, H1);
      box(0, wall_o+chan, y_uf, -3, 0, 8);
      box(x_c0+card_w-4, mw, -3, -clr, 0, H1);
      box(x_c0+card_w+0.4, mw, -3, y_a+3, 0, H1);
      box(mw-wall_o-chan, mw, y_uf, -3, 0, 8);
      box(mw/2-12, mw/2+12, y_a, y_a+2.5, 0, H1);
    }
    for (p=mounts) translate([p[0], p[1], -0.01]) cylinder(d=3+2*clr, h=4.5, $fn=20);
  }
}

module hoodtop() {
  translate([0,0,z_hood]) {
    box(hood_x0, mw-hood_x0, t_pad-4, y_fw0, 0, 2.5);
    for (m=[0,1]) mirror_x(m) for (yy=[t_pad, y_fw0+4])
      if (yy < y_fw0) translate([hood_x0+hood_t/2, yy, -3.5]) cylinder(d=2.4, h=3.6, $fn=16);
  }
}

// ---- 속기둥 (수) : 축 = +Y ----
module rod() {
  L = rod_end0 - t_pad;
  difference() {
    union() {
      translate([0, t_pad, 0]) rotate([-90,0,0]) cylinder(d=rod_d, h=L, $fn=32);
      translate([-peg/2, t_pad-3, -peg/2]) cube([peg, 3.01, peg]);                  // 네모 끝 (패들에 꽂힘)
      translate([0, y_nub0, 0]) cylinder(d=nub_d, h=sp_od/2-0.3, $fn=16);         // 돌기 (위쪽 기준)
    }
    translate([-5, t_pad-4, -rod_d/2-1]) cube([10, L+5, 1+0.6]);                  // 바닥 평평 (출력용)
  }
}
module shaft() {
  translate([hood_x0-6.5, gy, gz]) rotate([0,90,0]) linear_extrude(mw+2-(hood_x0-6.5)) hex2d(shaft_af);
}
module pinion() difference() { linear_extrude(arm_t-0.4) gear2d(gn, gm); translate([0,0,-1]) linear_extrude(9) hex2d(shaft_af+0.25); }
module dwheel() difference() {
  cylinder(d=12, h=2.6, $fn=48);
  for (i=[0:n_click-1]) rotate([0,0,i*360/n_click]) translate([6,0,-1]) linear_extrude(5) polygon([[0.1,0],[-0.8,0.65],[-0.8,-0.65]]);
  translate([0,0,-1]) linear_extrude(9) hex2d(shaft_af+0.25);
}
module knob() difference() {
  union() { cylinder(d=18, h=6, $fn=48); for (i=[0:11]) rotate([0,0,i*30]) translate([9,0,0]) cylinder(d=2.4, h=6, $fn=12); }
  translate([0,0,-1]) linear_extrude(9) hex2d(shaft_af+0.25);
  translate([0,6.5,5]) cylinder(d=1.5, h=2, $fn=8);    // 눈금 표시점
}

// ---- 대체 스프링 (지그재그, 겉기둥에 들어가는 크기) ----
zs_len = (y_fw0 + sp_len - 2) - rod_end0 + 0.5;   // 약간 눌린 상태로 들어감
zs_n = 18;  zs_t = 0.5;  zs_a = 5.4;  zs_h = 3;
module zspring() {   // 출력 방향 그대로 (높이 = zs_h)
  p = (zs_len - 2*1.2)/zs_n;
  linear_extrude(zs_h) {
    translate([0, -zs_a/2]) square([1.2, zs_a]);
    translate([zs_len-1.2, -zs_a/2]) square([1.2, zs_a]);
    for (i=[0:2*zs_n-1]) {
      x0 = 1.2 + i*p/2;  up = (i%2==0);
      hull() {
        translate([x0, up ? -zs_a/2 : zs_a/2-zs_t]) square([zs_t, zs_t]);
        translate([x0 + p/2 - zs_t*(i==2*zs_n-1 ? 1 : 0), up ? zs_a/2-zs_t : -zs_a/2]) square([zs_t, zs_t]);
      }
    }
  }
}
// ---- 대체 칼날 (PLA, 동작 확인 + 절취선 제품용) ----
module dblade() hull() { cube([blade_len, blade_w-2.5, 0.6]); translate([0, blade_w-0.01, 0]) cube([blade_len, 0.01, 0.2]); }

module card_preview() {
  for (k=[0:n_cells-1]) translate([x_c0, 0, tt(p_set) + k*cell_p]) {
    cube([card_w, card_t, cell_p-0.4]);
    translate([(card_w-bub_l)/2, -bub_h, (cell_p-bub_w)/2]) cube([bub_l, bub_h, bub_w]);
  }
}
module blade() translate([x_bl, y_t0, gap_z]) rotate([0,0,b_ang]) translate([0,-blade_w,-blade_t/2]) cube([blade_len, blade_w, blade_t]);
module rods_placed(s=0) for (m=[0,1]) mirror_x(m) for (zc=sp_zs) translate([sp_x, s, zc]) rotate([0,-90,0]) rod();   // 돌기가 바깥(-x)
pin_ph = 9;   // 피니언 위상 (톱니 맞물림, 검사로 결정)
module shaft_parts(ang=0) {
  shaft();
  for (x=[wall_o+clr+0.2, x_s1+clr+0.2]) translate([x, gy, gz]) rotate([0,90,0]) rotate([0,0,pin_ph+ang]) pinion();
  translate([-2.6, gy, gz]) rotate([0,90,0]) dwheel();
  translate([hood_x0-6.5, gy, gz]) rotate([0,90,0]) knob();
}

// =====================================================================
if (part=="assembly" || part=="assembly_cards") {
  s = press ? S : 0;
  color("#2b2b30") body();
  translate([0,s,0]) { color("#ff7a1a") carrier(); color("#ffc890") tframe(); color("silver") blade();
                       color("#2f6fd6") shaft_parts(); }
  color("#c0c4ca") rods_placed(s);
  color("#4f86c6") anvil();
  color("#6a7a96") holder1();
  color("#3a3a42") hoodtop();
  color([0.75,0.88,1.0]) card_preview();
}
else if (part=="body")    body();
else if (part=="carrier") { if (print) rotate([90,0,0]) translate([0,-(t_pad-3),0]) carrier(); else carrier(); }
else if (part=="tframe")  { if (print) translate([0,0,tt(p_set)]) mirror([0,0,1]) tframe(); else tframe(); }
else if (part=="anvil")   { if (print) rotate([-90,0,0]) translate([0,-y_an1,0]) anvil(); else anvil(); }
else if (part=="holder1") { if (print) translate([0,0,-z_cu]) holder1(); else holder1(); }
else if (part=="hoodtop") { if (print) translate([0,0,z_hood+2.5]) mirror([0,0,1]) hoodtop(); else hoodtop(); }
else if (part=="rod")     { if (print) translate([0,0,rod_d/2-0.6]) rotate([90,0,0]) rotate([0,0,0]) rod(); else rod(); }
else if (part=="shaft")   { if (print) translate([0,0,shaft_af/2]) rotate([0,90,0]) rotate([0,0,30]) linear_extrude(mw+2-(hood_x0-6.5)) hex2d(shaft_af); else shaft(); }
else if (part=="pinion")  pinion();
else if (part=="dwheel")  dwheel();
else if (part=="knob")    knob();
else if (part=="zspring") zspring();
else if (part=="dblade")  dblade();
