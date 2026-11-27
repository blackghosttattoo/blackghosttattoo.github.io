// =====================================================================
//  1단계 개선 "테스트용" (stage1b_test)  ※ 실제 완성본과 별개
//  목적: 필라멘트 최소화. 기존 1단계 부품 재사용 + 바뀐 부품만 새로 출력.
//
//  재사용 (다시 출력 안 함): 카드 1장 홀더, 커팅 받침 바, PLA 대체 칼날(88mm)
//  새로 출력: body / carrier / tframe / hplate(높이 조절판) / slider(경사 밀대) /
//             rod ×4 (스프링 속기둥) / zspring ×4 (선택, 볼펜 스프링 대신)
//
//  변경점: 볼록부 16mm 기준 · 칼날 3° 작두식 · 스프링 4개(암수 홈, 멈춤 겸용) ·
//          바닥 가운데 경사 밀대(딸깍) · 톱니/핀 방식 삭제 · 덮개는 완성본에서만
// =====================================================================
part  = "assembly";
print = false;
press = 0;
p_view = 30;     // 미리보기용 칸 간격

/* ---------- 실측 / 기준 ---------- */
card_w = 80;  cell_p = 29.8;  bub_l = 67;  bub_w = 15.5;  bub_h = 16;  card_t = 0.5;  n_cells = 5;
bub_h_max = 16;
p_min = 24;  p_max = 36;  w_max = 86;
b_ang = 3;  blade_t = 0.5;  blade_w = 18;  blade_len = 90;
clr = 0.35;
$fn = 32;

// ---- 1단계와 같은 기준 좌표 (홀더·받침 바 재사용) ----
wall_o = 3;  chan = 4.5;  g_t = 2.5;  arm_t = chan - 2*clr;
slot_w = w_max + 1.6 + g_t + 0.8;
x_s0 = wall_o + chan;  x_s1 = x_s0 + slot_w;  mw = x_s1 + chan + wall_o;
x_c0 = x_s0 + 0.8;  lip_x1 = x_c0 + 4;
gap_z = 70;  ph = 2;  z_pl0 = gap_z - ph;  z_pl1 = gap_z + ph;
z_cu = z_pl1 + 11;
y_a = card_t + clr;
y_an1 = y_a + 10;                 // 기존 받침 바 깊이 10
g_end = y_a + 6;                  // 기존 받침 바 홈 끝
y_fw0 = -38.55;                   // 기존과 같은 앞면
y_sb  = 37.85;                    // 기존과 같은 뒤끝
mounts = [[(wall_o+chan)/2, y_fw0+5], [(wall_o+chan)/2, y_sb-5],
          [mw-(wall_o+chan)/2, y_fw0+5], [mw-(wall_o+chan)/2, y_sb-5]];
function tt(p) = gap_z - p;
tt_lo = tt(p_max);  tt_hi = tt(p_min);

// ---- 칼날 (작두식) ----
dy_b  = blade_len*sin(b_ang);
y_ld0 = -bub_h_max - 1;
y_t0  = y_ld0 - dy_b;
ot    = 1.0;                      // 늦게 닿는 끝이 카드 뒤로 지나가는 거리
S     = (y_a + ot) - y_t0;        // 누르는 거리
e_t   = 3;
tip0  = y_t0 - e_t;  tp_len = 18;  tip_h = 1.0;
x_bl  = x_c0 - 5;
t_tf  = y_t0 - 1.0;  t_tr = card_t;
t_pad = y_fw0 - S;

// ---- 스프링 기둥 (테스트용: 옆판 바깥) ----
sp_x = -5.5;  sp_zs = [32, 78];  sp_od = 11;  sp_id = 7.2;  sp_len = 46;
sl_w = 2.4;  nub_d = 2.0;
y_nub0 = y_fw0 + 2.8;
rod_d = 6.6;  rod_end0 = y_nub0 + 2.5;  peg = 4;

// ---- 받침판 프레임 연결 (패들 귀의 핀 → 팔 앞 갈래 홈) ----
zp = 30;  yp_c = t_pad + 4.5;

// ---- 높이 조절판 + 경사 밀대 ----
arm_h  = 8;                       // 팔 높이 (받침판 아래)
skid_l = 12;
rail_h = 4;
yb0 = 24.6;  yb1 = 28.6;          // 조절판 가로대 y
rise = 12;  run = 36;             // 12mm 오르내림 / 36mm 이동 (1mm당 3mm)
sl_y0 = 24.0;  sl_y1 = 27.6;      // 밀대 몸 y
arm_y0 = 28.2; arm_y1 = 29.2;     // 딸깍 팔 y
cw_f1 = 23.6;  cw_b0 = 29.6;      // 홈 앞벽 뒤면 / 뒷벽 앞면
lip_z = 1.6;  sl_base = 3;
leg_x = mw/2;
// 밀대 위치(오른쪽으로 갈수록 높음): u = 0..run → 높이 = u/3
function ramp_u(p) = (p_max - p)*run/rise;
sl_x0 = mw/2 - (run/2) - 6;
ch_x0 = leg_x - 6 - run - 0.4;     // 밀대 홈 왼쪽 끝
ch_x1 = leg_x + 6 + run + 0.4;     // 밀대 홈 오른쪽 끝

echo(str("누르는 거리 S = ", S, "  (칼날 앞끝 최대 깊이 ", y_t0+S+dy_b, " / 기존 홈 끝 ", g_end, ")"));
echo(str("본체 폭(스프링 기둥 포함) = ", mw - 2*(sp_x - sp_od/2)));

// =====================================================================
module box(x0,x1,y0,y1,z0,z1) { translate([x0,y0,z0]) cube([x1-x0, y1-y0, z1-z0]); }
module rbox(x0,x1,y0,y1,z0,z1,r=2) { hull() for (x=[x0+r,x1-r], y=[y0+r,y1-r]) translate([x,y,z0]) cylinder(r=r, h=z1-z0, $fn=16); }
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

// ---------------- 스프링 겉기둥 (암) ----------------
module bayonet_cut(zc) {
  translate([sp_x, 0, zc]) {
    box(-sl_w/2, sl_w/2, y_fw0-1, y_fw0+5.2, 0, sp_od);                           // A 입구 홈 (위)
    intersection() {                                                               // B 돌리는 홈
      translate([0, y_fw0+2.6, 0]) rotate([-90,0,0]) cylinder(d=sp_od+2, h=2.6, $fn=40);
      box(-sp_od, sl_w/2, y_fw0-1, y_fw0+10, -sl_w/2, sp_od);
    }
    box(-sp_od, 0, y_nub0-sl_w/2, y_nub0 + S + sl_w/2 + 0.5, -sl_w/2, sl_w/2);   // C 긴 홈 (+잠김)
  }
}
module sleeves() {
  difference() {
    union() {
      for (zc=sp_zs) translate([sp_x,0,zc]) ycyl(sp_od, y_fw0, y_fw0+sp_len, 40);
      for (zc=sp_zs) box(sp_x, 0.01, y_fw0, y_fw0+sp_len, zc-1.5, zc+1.5);
      for (yy=[y_fw0, y_fw0+sp_len-8]) box(sp_x-1, sp_x+1, yy, yy+8, 0, sp_zs[1]);    // 받침 기둥 2개
    }
    for (zc=sp_zs) translate([sp_x,0,zc]) ycyl(sp_id, y_fw0-1, y_fw0+sp_len-2, 40);
    for (zc=sp_zs) bayonet_cut(zc);
  }
}

// ---------------- 본체 ----------------
module body() {
  for (m=[0,1]) mirror_x(m) {
    difference() {
      union() {
        box(0, wall_o, y_fw0, y_sb, 0, z_cu);
        ledge(y_fw0, -1, z_pl0-0.1, 2.5);                                          // 칼날판 턱
        ledge(y_a, y_an1, gap_z-6, 2);                                             // 받침 바 턱 (기존과 같음)
        box(wall_o-0.01, wall_o+2, y_an1+clr, y_an1+2.5, gap_z-6-2.8, gap_z+6);
        for (yy=[y_fw0+1, y_sb-9]) translate([0, yy+8, 0]) rotate([90,0,0]) linear_extrude(8)
          polygon([[wall_o-0.01,z_cu],[wall_o+chan,z_cu],[wall_o+chan,z_cu-5],[wall_o-0.01,z_cu-5-chan]]);
        for (yy=[y_fw0+5, y_sb-5]) translate([(wall_o+chan)/2, yy, z_cu-0.01]) cylinder(d=3, h=4, $fn=20);
      }
      gwin(y_fw0+12, y_a-3, 6, gap_z-12);                                          // 창
      // 패들 귀가 들어오는 홈 (누를 때)
      translate([-1,0,0]) rotate([90,0,90]) linear_extrude(wall_o+clr+1.01)
        polygon([[y_fw0-1,zp-4.5],[y_fw0+9.5,zp-4.5],[y_fw0+9.5,zp+4.5],[y_fw0+4,zp+10],[y_fw0-1,zp+4.5]]);
      // 높이 조절판 가로대가 오르내리는 홈 (위로 열림)
      box(1.5, wall_o+0.01, yb0-0.3, yb1+0.3, tt_lo-arm_h-rail_h-1, z_cu+1);
    }
    sleeves();
  }
  // 아래 앞 연결대
  box(0, mw, y_fw0, y_fw0+5, 0, 4);
  // 밀대 홈 (앞벽·뒷벽, 아래 턱)
  difference() {
    union() {
      box(0, mw, cw_f1-2.5, cw_f1, 0, 10);                                         // 앞벽
      box(0, mw, cw_b0, cw_b0+2.5, 0, 10);                                         // 뒷벽
      box(ch_x0-2, ch_x0+0.01, cw_f1-0.01, cw_b0+0.01, 0, 10);                     // 왼쪽 끝막이
      box(ch_x1-0.01, ch_x1+2, cw_f1-0.01, cw_b0+0.01, 0, 10);                     // 오른쪽 끝막이
      box(ch_x0-2, ch_x1+2, cw_f1-0.01, cw_f1+1.2, 0, lip_z);                      // 아래 턱 (앞)
      box(ch_x0-2, ch_x1+2, cw_b0-1.2, cw_b0+0.01, 0, lip_z);                      // 아래 턱 (뒤)
    }
    // 딸깍 홈 (뒷벽 앞면, 3mm마다)
    for (k=[0:12]) translate([leg_x - 6 - run + 6 + k*run/rise, cw_b0, lip_z+3.6]) cylinder(d=1.8, h=5, center=true, $fn=16);
    // 바닥 눈금 (아래에서 읽힘)
    for (k=[0:2:12]) translate([leg_x - 6 - run + 6 + k*run/rise, cw_f1-1.25, -0.01]) mirror([1,0,0])
      linear_extrude(0.6) text(str(p_max-k), size=1.8, halign="center", valign="center", font="Liberation Sans:style=Bold");
  }
}

// ---------------- 캐리어 (패들 + 작두식 칼날판 + 귀 핀) ----------------
module blade_slot() {
  translate([x_bl, y_t0, gap_z]) rotate([0,0,b_ang])
    translate([-1, -(blade_w+0.3), -(blade_t+0.2)/2]) cube([blade_len+2, blade_w+0.3+12, blade_t+0.2]);
}
module carrier() {
  difference() {
    union() {
      rbox(sp_x-sp_od/2+0.3, mw-sp_x+sp_od/2-0.3, t_pad-3, t_pad, 26, sp_zs[1]+6, 1.4);
      translate([wall_o+clr, 0, 0]) rotate([90,0,90]) linear_extrude(mw-2*wall_o-2*clr)
        polygon([[t_pad-0.1, z_pl0], [tip0-tp_len, z_pl0], [tip0, gap_z-tip_h],
                 [tip0, gap_z+tip_h], [tip0-tp_len, z_pl1], [t_pad-0.1, z_pl1]]);
      for (m=[0,1]) mirror_x(m) {
        box(0.6, wall_o+clr-0.3, t_pad-0.1, t_pad+8, zp-3, zp+3);                  // 귀
        translate([wall_o+clr-0.31, yp_c, zp]) rotate([0,90,0]) cylinder(d=2.5, h=chan-0.4, $fn=20);   // 핀
      }
    }
    box(16, mw-16, t_pad-4, t_pad+1, 36, z_pl0-3);
    for (x=[x_s0+10:12:x_s1-18]) box(x, x+8, t_pad+3, tip0-tp_len-3, z_pl0-1, z_pl1+1);
    blade_slot();
    for (m=[0,1]) mirror_x(m) for (zc=sp_zs) translate([sp_x-(peg+0.3)/2, t_pad-4, zc-(peg+0.3)/2]) cube([peg+0.3, 5, peg+0.3]);
  }
}

// ---------------- 받침판 프레임 ----------------
module tframe(p=p_view) {
  t = tt(p);
  difference() {
    union() {
      box(wall_o+clr, mw-wall_o-clr, t_tf, t_tr, t-3, t);                           // 받침판
      for (x=[wall_o+clr, x_s1+clr]) {
        box(x, x+arm_t, t_pad+1.2, t_tr, t-arm_h, t);                               // 팔 (아래면 = 미끄럼 발)
        box(x, x+arm_t, t_pad+1.2, t_pad+7.8, t-22, t);                             // 앞 갈래 (핀 받음)
      }
    }
    for (x=[wall_o-1, x_s1-1]) box(x, x+chan+2, yp_c-1.5, yp_c+1.5, t-23, t-2.5);   // 아래로 열린 홈
  }
}

// ---------------- 높이 조절판 ----------------
module hplate(p=p_view) {
  rt = tt(p) - arm_h;                         // 레일 윗면 = 팔 아래면
  translate([0,0,0]) {
    for (x=[wall_o+clr, x_s1+clr]) box(x, x+arm_t, t_tr-skid_l, yb0+0.01, rt-rail_h, rt);   // 레일
    box(1.5+clr, mw-1.5-clr, yb0, yb1, rt-rail_h, rt);                                       // 가로대 (홈에서 오르내림)
    // 가운데 다리 (끝 둥글게)
    translate([leg_x-3, (sl_y0+sl_y1)/2-1.5, 0]) {
      box(0, 6, 0, 3, (lip_z+sl_base+ramp_u(p)/3) + 2.15, rt-rail_h+0.01);
    }
    translate([leg_x, (sl_y0+sl_y1)/2-1.5, lip_z+sl_base+ramp_u(p)/3+2+0.15]) rotate([-90,0,0]) cylinder(r=2, h=3, $fn=24);
  }
}

// ---------------- 경사 밀대 (좌표: u=0 위치) ----------------
module slider() {
  L = run + 12;                               // 경사 36 + 양끝 평평 6씩
  difference() {
    union() {
      // 몸 + 경사 (오른쪽 높음): 다리 기준으로 밀대를 왼쪽으로 옮기면 높은 쪽이 다리 밑으로
      translate([0, sl_y0, lip_z]) rotate([90,0,0]) mirror([0,0,1]) linear_extrude(sl_y1-sl_y0)
        polygon([[0,0],[L,0],[L,sl_base],[L-6,sl_base],[6,sl_base+rise],[0,sl_base+rise]]);
      // 딸깍 팔: 한쪽 끝만 붙은 얇은 판 + 둥근 돌기
      box(L-14, L-12, sl_y1-0.01, arm_y0+0.01, lip_z, lip_z+6);
      box(4, L-12, arm_y0, arm_y1, lip_z, lip_z+6);                                  // 딸깍 팔 (뒤 턱 위에 얹혀 미끄러짐)
      translate([6, arm_y1, lip_z+3.6]) cylinder(d=1.6, h=2.5, center=true, $fn=16);
    }
    // 바닥 미끄럼 방지 홈 (턱 사이로 손톱·펜 끝으로 밀기)
    for (x=[9:4:L-9]) box(x, x+1.6, 24.6, 28.0, lip_z-1, lip_z+0.8);
  }
}
// 미리보기용 배치: 칸 간격 p일 때 밀대 위치
function sl_shift(p) = leg_x - (6 + run - ramp_u(p));    // 다리가 경사 위 u 지점에 오도록
module slider_at(p=p_view) translate([sl_shift(p), 0, 0]) slider();

// ---------------- 속기둥 (수) ----------------
module rod() {
  L = rod_end0 - t_pad;
  difference() {
    union() {
      translate([0, t_pad, 0]) rotate([-90,0,0]) cylinder(d=rod_d, h=L, $fn=32);
      translate([-peg/2, t_pad-3, -peg/2]) cube([peg, 3.01, peg]);
      translate([0, y_nub0, 0]) cylinder(d=nub_d, h=sp_od/2-0.3, $fn=16);
    }
    translate([-5, t_pad-4, -rod_d/2-1]) cube([10, L+5, 1+0.6]);
  }
}
module rods_placed(s=0) for (m=[0,1]) mirror_x(m) for (zc=sp_zs) translate([sp_x, s, zc]) rotate([0,-90,0]) rod();

// ---------------- 지그재그 스프링 (선택) ----------------
zs_len = (y_fw0 + sp_len - 2) - rod_end0 + 0.5;
zs_n = 13;  zs_t = 0.45;  zs_a = 5.4;  zs_h = 3;
module zspring() {
  p = (zs_len - 2*1.2)/zs_n;
  linear_extrude(zs_h) {
    translate([0, -zs_a/2]) square([1.2, zs_a]);
    translate([zs_len-1.2, -zs_a/2]) square([1.2, zs_a]);
    for (i=[0:2*zs_n-1]) { x0 = 1.2 + i*p/2;  up = (i%2==0);
      hull() { translate([x0, up ? -zs_a/2 : zs_a/2-zs_t]) square([zs_t, zs_t]);
               translate([x0 + p/2 - (i==2*zs_n-1 ? zs_t : 0), up ? zs_a/2-zs_t : -zs_a/2]) square([zs_t, zs_t]); } }
  }
}

// ---------------- PLA 대체 칼날 (90mm, 한쪽이 얇아짐) ----------------
module dblade() hull() { cube([blade_len, blade_w-2.5, 0.6]); translate([0, blade_w-0.01, 0]) cube([blade_len, 0.01, 0.2]); }

// ---------------- 재사용 부품 (미리보기용, 출력 안 함) ----------------
module anvil_old() difference() { box(wall_o+clr, mw-wall_o-clr, y_a, y_an1, gap_z-6+0.15, gap_z+6); box(0, mw, y_a-1, g_end, gap_z-0.5, gap_z+0.5); }
module holder_old() translate([0,0,z_cu]) difference() {
  union() {
    for (m=[0,1]) mirror_x(m) box(0, wall_o+chan, y_fw0+1, y_sb-1, 0, 3);
    box(0, mw, -20.5, -17.5, 0, 3);  box(0, mw, y_a, y_a+3, 0, 3);
    box(0, lip_x1, -3, -clr, 0, 55);  box(0, x_c0-0.4, -3, y_a+3, 0, 55);  box(0, wall_o+chan, -20.5, -3, 0, 8);
    box(x_c0+card_w-4, mw, -3, -clr, 0, 55);  box(x_c0+card_w+0.4, mw, -3, y_a+3, 0, 55);  box(mw-wall_o-chan, mw, -20.5, -3, 0, 8);
    box(mw/2-12, mw/2+12, y_a, y_a+2.5, 0, 55);
  }
  for (pp=mounts) translate([pp[0], pp[1], -0.01]) cylinder(d=3+2*clr, h=4.5, $fn=20);
}
module blade() translate([x_bl, y_t0, gap_z]) rotate([0,0,b_ang]) translate([0,-blade_w,-blade_t/2]) cube([blade_len, blade_w, blade_t]);
module card_preview(p=p_view) for (k=[0:n_cells-1]) translate([x_c0, 0, tt(p) + k*cell_p]) {
  cube([card_w, card_t, cell_p-0.4]);  translate([(card_w-bub_l)/2, -bub_h, (cell_p-bub_w)/2]) cube([bub_l, bub_h, bub_w]); }

// =====================================================================
if (part=="assembly") {
  s = press ? S : 0;
  color("#2b2b30") body();
  translate([0,s,0]) { color("#ff7a1a") carrier(); color("#ffc890") tframe(); color("silver") blade(); }
  color("#c0c4ca") rods_placed(s);
  color("#2f6fd6") hplate();  color("#e8650a") slider_at();
  color("#4f86c6") anvil_old();  color("#6a7a96") holder_old();
  color([0.75,0.88,1.0]) card_preview();
}
else if (part=="body")    body();
else if (part=="carrier") { if (print) rotate([90,0,0]) translate([0,-(t_pad-3),0]) carrier(); else carrier(); }
else if (part=="tframe")  { if (print) translate([0,0,tt(p_view)]) mirror([0,0,1]) tframe(); else tframe(); }
else if (part=="hplate")  { if (print) translate([0,0,tt(p_view)-arm_h]) mirror([0,0,1]) hplate(); else hplate(); }
else if (part=="slider")  { if (print) translate([0,0,-lip_z]) slider(); else slider(); }
else if (part=="rod")     { if (print) translate([0,0,rod_d/2-0.6]) rod(); else rod(); }
else if (part=="zspring") zspring();
else if (part=="dblade")  dblade();
