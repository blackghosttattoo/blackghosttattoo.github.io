include <t_lib.scad>
view = 0;  kx = 45;   // 칼날 팔 x 위치 (5 = 대기, 95 = 끝)
// ---- 새 부품 (예상) ----
bar_y0 = -36; bar_y1 = -26; bar_z0 = z_pl0-0.1; bar_z1 = bar_z0 + 2.2;   // 칼날판 턱 위에 얹히는 레일
module rail() {
  box(wall_o+clr, mw-wall_o-clr, bar_y0, bar_y1, bar_z0, bar_z1);
  box(wall_o+clr, mw-wall_o-clr, bar_y0+3, bar_y1-3, bar_z1-0.01, bar_z1+2);       // 위 돌출 (가이드)
}
module knife(x) {
  // 슬라이더 몸 (레일을 감쌈) + 손잡이 (앞으로) + 칼날 팔 (뒤로, 칸 사이 틈)
  translate([x,0,0]) {
    difference() { box(-2, 12, bar_y0-2, bar_y1+2, bar_z0-3, bar_z1+5); box(-3, 13, bar_y0+2.6, bar_y1-2.6, bar_z1-0.5, bar_z1+2.4); box(-3,13,bar_y0-0.1,bar_y1+0.1,bar_z0-0.01,bar_z1); }
    box(1, 9, t_pad-12, bar_y0-1.9, gap_z-1, gap_z+5);            // 손잡이 줄기
    rbox(-6, 16, t_pad-24, t_pad-12, gap_z-6, gap_z+10, 3);       // 손잡이 (패들 앞)
    box(0, 2.6, bar_y1+1.9, -1.5, gap_z-1.2, gap_z+1.2);          // 칼날 팔 (틈 속)
  }
}
module blade_seg(x) translate([x+2.6, -1.5, gap_z]) rotate([0,0,-40]) translate([0,0,-0.25]) linear_extrude(0.5) polygon([[0,0],[0,12],[7,4]]);
module carrier_v3() difference() {
  union() {
    rbox(sp_x-sp_od/2+0.3, mw-sp_x+sp_od/2-0.3, t_pad-3, t_pad, 26, sp_zs[1]+6, 1.4);
    for (m=[0,1]) mirror_x(m) { box(0.6, wall_o+clr-0.3, t_pad-0.1, t_pad+8, zp-3, zp+3);
      translate([wall_o+clr-0.31, yp_c, zp]) rotate([0,90,0]) cylinder(d=2.5, h=chan-0.4, $fn=20); }
  }
  box(6, mw-6, t_pad-4, t_pad+1, 36, 77);
  for (m=[0,1]) mirror_x(m) for (zc=sp_zs) translate([sp_x-(peg+0.3)/2, t_pad-4, zc-(peg+0.3)/2]) cube([peg+0.3, 5, peg+0.3]);
}
if (view==0) {
  color("#2b2b30") body(); color("#ff7a1a") carrier_v3(); color("#ffc890") tframe(); color("#c0c4ca") rods_placed(0);
  color("#2f6fd6") hplate(); color("#4f86c6") anvil_old(); color("#6a7a96") holder_old();
  color("#8e44ad") rail(); color("#e8650a") knife(kx); color("silver") blade_seg(kx);
  color([0.75,0.88,1.0]) card_preview();
}
if (view==1) {   // 위에서 (칼날 높이에서 자른 모습)
  intersection() { union() { color("#2b2b30") body(); color("#4f86c6") anvil_old(); color("#8e44ad") rail(); color("#e8650a") knife(kx);
    color([0.75,0.88,1.0]) card_preview(); color("#ff7a1a") carrier_v3(); } box(-30,140,-110,60,gap_z-3,gap_z+1.6); }
  color("silver") blade_seg(kx);
}
