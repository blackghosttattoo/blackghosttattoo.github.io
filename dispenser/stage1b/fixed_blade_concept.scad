include <t_lib.scad>
view = 0;  push = 0;          // 0 = 대기, 1 = 끝까지 누름
b_dy = 18;                    // 칼날 양 끝 앞뒤 차이
bl_x0 = x_c0-4;  bl_x1 = x_c0+card_w+4;
b_y0 = y_a+1;                 // 먼저 닿는 끝 (왼쪽)
pz1 = gap_z-1;  pz0 = gap_z-7;   // 미는 바 높이
module bline(dy=0) polygon([[bl_x0, b_y0+dy],[bl_x1, b_y0+b_dy+dy],[bl_x1, 40],[bl_x0, 40]]);
module blade_bar() difference() {     // 받침 바 자리: 위는 윗칸 받침, 아래는 칼날 고정
  union() {
    box(wall_o+clr, mw-wall_o-clr, y_a, 30, gap_z+0.6, gap_z+7);             // 위: 윗칸 뒤 받침 + 칼날 누름
    box(wall_o+clr, mw-wall_o-clr, y_a+b_dy+6, 30, gap_z-9, gap_z+7);         // 뒤 기둥
    for (x=[wall_o+clr, mw-wall_o-clr-3]) box(x, x+3, y_a, 30, gap_z-9, gap_z+7);  // 양 옆
  }
}
module fblade() translate([0,0,gap_z-0.25]) linear_extrude(0.5) intersection() { bline(); polygon([[bl_x0,b_y0],[bl_x1,b_y0+b_dy],[bl_x1,b_y0+b_dy+14],[bl_x0,b_y0+14]]); }
module carrier_v4(u=0) translate([0,u,0]) difference() {
  union() {
    rbox(sp_x-sp_od/2+0.3, mw-sp_x+sp_od/2-0.3, t_pad-3, t_pad, 26, sp_zs[1]+6, 1.4);
    for (x=[wall_o+clr, mw-wall_o-clr-4]) box(x, x+4, t_pad-0.1, -1, pz0, pz1);   // 양 옆 팔
    box(wall_o+clr, mw-wall_o-clr, -12, -1, pz0, pz1);                            // 미는 바 (앞 끝 = 카드 앞)
    for (m=[0,1]) mirror_x(m) { box(0.6, wall_o+clr-0.3, t_pad-0.1, t_pad+8, zp-3, zp+3);
      translate([wall_o+clr-0.31, yp_c, zp]) rotate([0,90,0]) cylinder(d=2.5, h=chan-0.4, $fn=20); }
  }
  box(14, mw-14, t_pad-4, t_pad+1, 34, 76);
  for (m=[0,1]) mirror_x(m) for (zc=sp_zs) translate([sp_x-(peg+0.3)/2, t_pad-4, zc-(peg+0.3)/2]) cube([peg+0.3, 5, peg+0.3]);
}
U = push*(S);
module cards() { color([0.75,0.88,1.0]) for (k=[1:n_cells-1]) translate([x_c0,0,tt(30)+k*cell_p]) { cube([card_w,card_t,cell_p-0.4]); translate([(card_w-bub_l)/2,-bub_h,(cell_p-bub_w)/2]) cube([bub_l,bub_h,bub_w]); }
  color([0.55,0.75,1.0]) translate([x_c0,U,tt(30)]) { cube([card_w,card_t,cell_p-0.4]); translate([(card_w-bub_l)/2,-bub_h,(cell_p-bub_w)/2]) cube([bub_l,bub_h,bub_w]); } }
if (view==0) {
  color("#2b2b30") body(); color("#ff7a1a") carrier_v4(U); color("#ffc890") tframe(30); color("#c0c4ca") rods_placed(0);
  color("#2f6fd6") hplate(); color("#8e44ad") blade_bar(); color("silver") fblade(); color("#6a7a96") holder_old(); cards();
}
if (view==1) intersection() { union() { color("#2b2b30") body(); color("#ff7a1a") carrier_v4(U); color("#8e44ad") blade_bar(); cards(); } box(-30,140,-110,60,pz0,gap_z-0.3); }
if (view==1) color("silver") fblade();
