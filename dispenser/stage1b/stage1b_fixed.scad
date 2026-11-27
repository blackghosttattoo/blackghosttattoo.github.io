// =====================================================================
//  사선 고정 칼날 테스트 (stage1b_fixed)  ※ 테스트용, 완성본과 별개
//  칼날은 카드 뒤에 사선으로 고정, 패들의 미는 바가 아래 칸을 뒤로 밀어 벰.
//
//  새로 출력: bholder(칼날 받침대) · pusher(미는 바 패들) · tstop ×2(받침판 고정쇠)
//  재사용   : stage1b_test 의 본체 · 받침판 프레임 · 높이 조절판 · 경사 밀대 ·
//             속기둥 4 · 지그재그 스프링 4 · 카드 홀더(1단계)
//  빼는 것  : 기존 패들, 커팅 받침 바, PLA 칼날
//  칼날     : 18mm 커터날 (끝 1마디 부러뜨려 85~92mm)
// =====================================================================
include <stage1b_test.scad>
part  = "fx_assembly";     // fx_assembly / bholder / pusher / tstop / tstop_r
print = false;
fx_press = 0;              // 미리보기: 0 대기 ~ 1 끝까지 누름

// ---- 사선 칼날 ----
fb_a   = 11.5;                         // 칼날 기울기
fb_x0  = 5.8;                          // 날 왼쪽 끝 x
fb_y0  = y_a + 0.75;                   // 날 왼쪽 끝 y (카드 뒤 1.1mm)
fb_L   = 92;                           // 홈 길이 (날 쪽)
fb_w   = 18.3;                         // 홈 폭 (날 18)
fb_t   = 0.75;                         // 홈 두께 (날 0.5, 다리 처짐 여유)
fb_sk  = 10.4;                         // 끝이 비스듬한 양 (커터날 부러뜨린 선)
fb_z   = gap_z;                        // 날 높이 = 절취선
hz0    = fb_z - 0.3;                   // 받침대 아래면 (홈 바닥)
hz1    = hz0 + fb_t;                   // 홈 윗면
hz_top = 74;
hy1    = 40.5;                         // 받침대 뒤끝
lip_y  = 23.8;                         // 이 뒤로는 날 아래 받침
fb_c = cos(fb_a);  fb_s = sin(fb_a);
function fb_edge_y(x) = fb_y0 + (x - fb_x0)*tan(fb_a);

// ---- 미는 바 ----
pb_z0 = 63.6;  pb_z1 = gap_z - 0.8;    // 미는 바 높이 (볼록부 위 ~ 절취선 아래)
pb_y1 = -1;                            // 미는 면 (대기)
pb_y0 = -30;
pp_z0 = z_pl0;  pp_z1 = z_pl0 + 3;     // 연결판 (칼날판 턱 위)
pp_y1 = -25;
pb_x0 = wall_o + 2.5 + 0.4;            // 턱(2.5) 피해서

echo(str("끝까지 눌렀을 때 미는 면 y = ", pb_y1 + S, " / 카드 오른쪽 끝 날 위치 y = ", fb_edge_y(x_c0+card_w)));

// ---------------- 칼날 홈 (평면 모양) ----------------
module fb_pocket2d(grow=0) {
  e0 = [fb_x0, fb_y0];  u = [fb_c, fb_s];  n = [-fb_s, fb_c];
  polygon([e0 - grow*u - grow*n, e0 + (fb_L+grow)*u - grow*n,
           e0 + (fb_L+grow)*u + fb_sk*u + (fb_w+grow)*n, e0 - grow*u + fb_sk*u + (fb_w+grow)*n]);
}
module fblade_preview() translate([0,0,fb_z-0.25]) linear_extrude(0.5) offset(delta=-0.3) fb_pocket2d();

// ---------------- 칼날 받침대 (기존 커팅 받침 바 자리) ----------------
module bholder() difference() {
  union() {
    // 앞: 양 옆 다리가 받침 바 턱(z 64)에 얹힘, 뒤면이 기존 멈춤 블록에 걸림
    for (m=[0,1]) mirror_x(m) box(wall_o+clr, wall_o+2.0, y_a, y_an1, gap_z-6+0.05, hz_top);
    box(wall_o+clr, mw-wall_o-clr, y_a, y_an1, hz1, hz_top);
    // 뒤: 본체 모서리 블록을 피해 좁게
    box(7.9, mw-7.9, y_an1-0.01, hy1, hz1, hz_top);
    box(5.6, mw-5.6, y_an1-0.01, 28.4, hz1, hz_top);
    // 홈 둘레 (날 높이 층): 날 뒤쪽과 양 끝만, 앞은 열림
    intersection() {
      box(5.6, mw-5.6, y_a, hy1, hz0, hz1+0.01);
      difference() { linear_extrude(200) offset(delta=2.5) fb_pocket2d(); translate([0,0,-1]) linear_extrude(202) half_front(); }
    }
    box(7.9, mw-7.9, lip_y, hy1, hz0-1.2, hz1);                 // 뒤쪽 아래 받침 (날이 안 빠지게)
  }
  translate([0,0,hz0-0.01]) linear_extrude(hz1-hz0+0.01) fb_pocket2d();   // 칼날 홈 (아래로 열림, 뒤쪽은 받침이 막음)
  // 날 빼는 구멍 (위에서 눌러 빼기)
  for (x=[30, 70]) translate([x, fb_edge_y(x)+10, hz1-0.1]) cylinder(d=5, h=20, $fn=24);
}
module half_front() polygon([[0, -10], [mw, -10], [mw, fb_edge_y(mw) - 0.01], [0, fb_edge_y(0) - 0.01]]);

// ---------------- 미는 바 패들 ----------------
module pusher() difference() {
  union() {
    rbox(sp_x-sp_od/2+0.3, mw-sp_x+sp_od/2-0.3, t_pad-3, t_pad, 26, sp_zs[1]+6, 1.4);   // 패들 판
    box(wall_o+clr, mw-wall_o-clr, t_pad-0.1, pp_y1, pp_z0, pp_z1);                     // 연결판
    box(pb_x0, mw-pb_x0, pb_y0, pb_y1, pb_z0, pb_z1);                                    // 미는 바
    // 미는 바 아래 경사 (출력 시 서포트 없이)
    translate([pb_x0, 0, 0]) rotate([90,0,90]) linear_extrude(mw-2*pb_x0)
      polygon([[pb_y0-6, pp_z0+0.01], [pb_y0, pb_z0], [pb_y0+0.01, pb_z0], [pb_y0+0.01, pp_z0+0.01]]);
  }
  // 받침판 앞 갈래 + 고정쇠 지나가는 홈
  for (m=[0,1]) mirror_x(m) box(0.3, 8.2, t_pad-4, t_pad+1, 25, 59);
  box(14, mw-14, t_pad-4, t_pad+1, 30, 62);                                              // 창 (필라멘트 절약)
  for (x=[14:12:mw-24]) box(x, x+8, t_pad+3, pb_y0-8, pp_z0-1, pp_z1+1);                 // 연결판 구멍
  for (m=[0,1]) mirror_x(m) for (zc=sp_zs) translate([sp_x-(peg+0.3)/2, t_pad-4, zc-(peg+0.3)/2]) cube([peg+0.3, 5, peg+0.3]);
}

// ---------------- 받침판 고정쇠 (왼쪽, 오른쪽은 거울) ----------------
//  받침판 팔 위에 얹고, 앞 돌기는 갈래 뒤에, 뒤끝은 본체 앞면에 닿음 → 받침판이 뒤로 안 밀림
ts_y0 = t_pad + 7.8 + 0.25;  ts_y1 = y_fw0 - 0.25;
module tstop(p=p_view) {
  t = tt(p);
  translate([0, ts_y0, 0]) rotate([90,0,0]) mirror([0,0,1]) linear_extrude(ts_y1-ts_y0)
    polygon([[0.6, t-20], [3.0, t-20], [3.0, t+0.25], [7.0, t+0.25], [7.0, t+2.45], [3.0, t+2.45], [3.0, t+12], [0.6, t+12]]);
  box(3.0-0.01, 7.0, ts_y0, ts_y0+4, t-20, t-arm_h-0.3);       // 앞 돌기 (팔 아래, 갈래 바로 뒤)
}

// =====================================================================
if (part=="fx_assembly") {
  s = fx_press*S;
  color("#2b2b30") body();
  translate([0,s,0]) color("#ff7a1a") pusher();
  color("#c0c4ca") rods_placed(s);
  color("#ffc890") tframe();  color("#2f6fd6") hplate();  color("#e8650a") slider_at();
  color("#8e44ad") bholder();  color("silver") fblade_preview();
  for (m=[0,1]) mirror_x(m) color("#1d6b2f") tstop();
  color("#6a7a96") holder_old();
  color([0.75,0.88,1.0]) card_preview();
}
else if (part=="bholder") { if (print) translate([0,0,hz_top]) mirror([0,0,1]) bholder(); else bholder(); }
else if (part=="pusher")  { if (print) rotate([90,0,0]) translate([0,-(t_pad-3),0]) pusher(); else pusher(); }
else if (part=="tstop")   { if (print) translate([0,0,-0.6]) rotate([0,-90,0]) tstop(); else tstop(); }
else if (part=="tstop_r") { if (print) mirror([0,1,0]) translate([0,0,-0.6]) rotate([0,-90,0]) tstop(); else mirror_x(1) tstop(); }
