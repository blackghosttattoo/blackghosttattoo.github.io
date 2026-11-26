include <s1_lib.scad>   // stage1.scad 의 "if (part==" 이전 부분을 s1_lib.scad 로 저장해서 사용 (미리보기 전용)
view = 0;      // 0 전체, 1 스프링 단면(대기), 2 스프링 단면(누름), 3 톱니 확대
pr   = 0;      // 1 = 누른 상태
hood_d = 28;   // 후드 깊이
yh0 = y_fw0 - hood_d;
// ---- 스프링 겉기둥/속기둥 위치 ----
sx = [3.5, mw-3.5];  sz = 7;  tube_l = 40;
module gear2d(n, m) {     // 간단 톱니 (사다리꼴 이)
  r = n*m/2;
  union() { circle(r - m*0.9, $fn=48);
    for (i=[0:n-1]) rotate(i*360/n) polygon([[r-m*1.1,-m*0.55],[r+m,-m*0.3],[r+m,m*0.3],[r-m*1.1,m*0.55]]); }
}
// 후드 (패들 둘레 덮개)
module hood() {
  difference() {
    union() {
      for (x=[0, mw-3]) box(x, x+3, yh0, y_fw0+0.01, 0, z_cu);
      box(0, mw, yh0, y_fw0+0.01, z_cu-3, z_cu);
    }
    // 왼쪽 벽: 조절 손잡이 지나가는 홈
    box(-1, 4, yh0+3, y_fw0+2, zA0+2, zA0+12);
  }
}
// 겉기둥 (본체에 고정) - 단면 표시용
module sleeve(cut=false) {
  for (x=sx) translate([x, y_fw0+0.01, sz]) rotate([-90,0,0]) difference() {
    cylinder(d=10, h=tube_l, $fn=40);
    translate([0,0,2.5]) cylinder(d=7, h=tube_l-5, $fn=40);      // 안쪽 (스프링 공간)
    translate([0,0,-1]) cylinder(d=3.6, h=4, $fn=24);            // 앞 턱 구멍 (속기둥만 통과)
    if (cut) translate([-10,0,-1]) cube([10, 20, tube_l+2]);
  }
}
// 속기둥 (패들에 고정) + 머리(멈춤)
module rod(s) {
  for (x=sx) translate([x, t_pad+s, sz]) rotate([-90,0,0]) {
    cylinder(d=3.2, h=(y_fw0+2.5+0.5) - t_pad + 0.01, $fn=24);
    translate([0,0,(y_fw0+2.5+0.5)-t_pad]) cylinder(d=6.4, h=3, $fn=32);
  }
}
module spring_in(s, cut=false) {
  for (x=sx) {
    y0 = y_fw0+2.5+0.5+3 + s;  y1 = y_fw0+tube_l-2.5;
    translate([x, y0, sz]) rotate([-90,0,0]) difference() {
      linear_extrude(height=y1-y0, twist=-360*8, slices=160) translate([2.6,0]) circle(0.45,$fn=8);
      if (cut) translate([-10,0,-1]) cube([10,20,60]);
    }
  }
}
// 톱니: 받침 프레임 팔 앞끝 랙 + 패들 쪽 피니언(축은 x방향, 양쪽 연결)
gm = 1.0; gn = 12; gr = gn*gm/2;
gy = t_pad + 8; gz = tt(30) - 8;
module racks(dz=0) {
  for (x=[wall_o+clr, x_s1+clr]) translate([x, gy+gr, gz-9+dz]) {
    cube([arm_t, 2.2, 22]);
    for (k=[0:20]) translate([0, -0.01, k*gm*3.1416/3.1416*3.14]) cube([arm_t, 0.01, 0.01]);
    for (k=[0:6]) translate([0, 0, 1+k*3.1416]) rotate([0,90,0]) linear_extrude(arm_t) polygon([[0,0],[-1.57,0],[-0.8,-1.0],[ -0.77,-1.0]]);
  }
}
module rack_teeth(dz=0) {
  for (x=[wall_o+clr, x_s1+clr]) for (k=[0:6]) translate([x, gy+gr+0.01, gz-8+k*3.1416+dz])
    rotate([0,90,0]) linear_extrude(arm_t) polygon([[0,0],[-1.57,0],[-1.1,-1.05],[-0.47,-1.05]]);
}
module pinions(ang=0) {
  for (x=[wall_o+clr, x_s1+clr]) translate([x, gy, gz]) rotate([0,90,0]) rotate([0,0,ang]) linear_extrude(arm_t) gear2d(gn, gm);
  translate([-9, gy, gz]) rotate([0,90,0]) cylinder(d=3, h=mw+10, $fn=20);      // 연결 축
  // 바깥 손잡이 (딸깍 홈)
  translate([-9, gy, gz]) rotate([0,90,0]) difference() {
    cylinder(d=16, h=5, $fn=48);
    for (i=[0:17]) rotate([0,0,i*20]) translate([8,0,-1]) cylinder(d=1.6, h=7, $fn=10);
  }
  translate([-9, gy, gz]) rotate([0,90,0]) translate([0,5,-0.5]) cube([1.2, 3, 1], center=true);
}
module tframe_c() intersection() { tframe(); box(-1, mw+1, gy+gr+2.19, 200, -10, 200); }
module ear_cover() for (m=[0,1]) mirror_x(m) box(0.45, 3.1, t_pad-0.2, t_pad+18.1, zA0-4.1, zA0+16.1);
module paddle_ext() box(0.5, mw-0.5, t_pad-3, t_pad, 2, zA0-6+0.01);     // 패들 아래 연장 (속기둥 고정)

s = pr ? S : 0;
if (view==0) {
  color("#2b2b30") body();
  color("#3a3a42") hood();
  color("#55555f") sleeve();
  translate([0,s,0]) { color("#ff7a1a") { carrier(); paddle_ext(); ear_cover(); } color("#ffc890") tframe_c();
    color("silver") rod(0); color("#2f6fd6") pinions(); color("#ffc890") rack_teeth(); }
  color("#4f86c6") anvil();
  color("#6a7a96") holder1();
  color([0.75,0.88,1.0]) card_preview();
}
if (view==1 || view==2) {
  ss = view==2 ? S : 0;
  color("#55555f") sleeve(true);
  color("silver") spring_in(ss, true);
  translate([0,ss,0]) { color("#ff7a1a") rod(0); color("#ff7a1a") intersection(){ paddle_ext(); box(0,8,-200,200,0,30);} }
  color("#2b2b30") intersection() { body(); box(-1, 3, y_fw0-1, y_fw0+45, 0, 20); }
}
if (view==3) {
  color("#ff7a1a") intersection() { union(){ carrier(); paddle_ext(); } box(3.2, 20, t_pad-6, t_pad+25, gz-16, gz+16); }
  color([1,0.48,0.1,0.25]) ear_cover();
  color("#ffc890") intersection() { tframe_c(); box(-12, 20, t_pad-6, t_pad+45, gz-18, gz+16); }
  color("#ffc890") rack_teeth();
  color("#2f6fd6") intersection() { pinions(); box(-12, 14, -200, 200, -100, 200); }
}
