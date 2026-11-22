// 타투 카트리지 반자동 디스펜서 - 조립식 모듈 컨셉 (대략 치수, mm)
// 모듈 1개 = 1라인 = 박스 1개(카드 4장, 20개)
// 카드 4장을 박스에서 꺼낸 그대로 앞뒤로 겹쳐 투입 → 맨 앞 카드부터 소진 → 뒤 스프링이 다음 카드를 앞으로 밀어줌
// 모듈 옆면 도브테일 레일로 위에서 밀어 끼워 무한 연결

// ---- 블리스터 카드 가정 치수 ----
cell_p  = 21;
bub_w   = 16;
bub_h   = 10;
card_w  = 62;
bub_l   = 52;
card_t  = 0.6;
card_d  = 13;     // 카드 1장 두께(볼록부 포함) → 앞뒤 겹침 간격

// ---- 모듈 ----
slot_w  = 74;
wall    = 4;
mw      = slot_w + 2*wall;   // 모듈 폭 82
zf      = 80;                // 받침(게이트) 높이
mag_top = zf + 5*cell_p + 14;
ch_top  = zf + cell_p + 22;
ym      = -18;               // 매거진 앞면
yc      = -46;               // 커팅 챔버 앞면
yb      = 4*card_d + 30;     // 뒷면 (카드 4장 + 스프링)
tray_y  = -112;
dt      = 6;                 // 도브테일 크기

$fn = 36;

module rbox(s, r=1.5) {
  hull() for (x=[r,s[0]-r], y=[r,s[1]-r], z=[r,s[2]-r]) translate([x,y,z]) sphere(r, $fn=12);
}
module spring(h, r=3, wire=0.6, turns=5) {
  linear_extrude(height=h, twist=-360*turns, slices=turns*24) translate([r,0]) circle(wire, $fn=10);
}

module cell(tint) {
  color([0.93,0.95,0.97]) translate([0, 0, 0.6]) cube([card_w, card_t, cell_p-1.2]);
  color("#f4f4f4") translate([0, card_t, 0.6]) cube([card_w, 0.5, cell_p-1.2]);
  color([0.9,0.95,1.0]) translate([(card_w-bub_l)/2, -0.2, cell_p/2]) difference() {
    hull() for (x=[bub_w/2, bub_l-bub_w/2]) translate([x,0,0]) rotate([90,0,0]) cylinder(d=bub_w+1.4, h=0.6);
    hull() for (x=[bub_w/2, bub_l-bub_w/2]) translate([x,0.1,0]) rotate([90,0,0]) cylinder(d=bub_w-0.2, h=1);
  }
  translate([(card_w-bub_l)/2+5, -bub_h*0.55, cell_p/2]) rotate([0,90,0]) {
    color("#d8dde3") cylinder(d=9, h=24);
    color("#9aa3ad") translate([0,0,24]) cylinder(d1=9, d2=4, h=8);
    color("#555") translate([0,0,32]) cylinder(d=1, h=8);
    color(tint) translate([0,0,-6]) cylinder(d=6.5, h=6);
  }
}
module perf() { color("#9ab") for (x=[2:4:card_w-2]) translate([x, -0.05, cell_p-0.6]) cube([2, card_t+0.1, 1.2]); }
module card(n, tint) { for (k=[0:n-1]) translate([0,0,k*cell_p]) { cell(tint); if (k<n-1) perf(); } }

// 도브테일 단면
module dt_profile(e=0) { polygon([[0,-dt/2-e],[dt+e,-dt-e],[dt+e,dt+e],[0,dt/2+e]]); }

module shell() {
  difference() {
    union() {
      translate([0, tray_y, 0]) rbox([mw, yb-tray_y, 8], 2);
      translate([0, yc, 8]) rbox([mw, yb-yc, ch_top-8], 2);
      translate([0, ym, 8]) cube([mw, yb-ym, mag_top-8]);
      // 오른쪽: 수 도브테일 레일 2개
      for (y=[ym+14, yb-14]) translate([mw, y, 8]) linear_extrude(mag_top-16) dt_profile();
    }
    // 왼쪽: 암 도브테일 홈
    for (y=[ym+14, yb-14]) translate([0, y, 4]) mirror([1,0,0]) translate([-dt-0.4,0,0]) linear_extrude(mag_top) dt_profile(0.4);
    // 매거진 공간
    translate([wall, ym+3, zf]) cube([slot_w, yb-3-(ym+3), mag_top]);
    // 앞 창
    translate([wall+8, ym-1, ch_top+5]) rbox([slot_w-16, 8, mag_top-ch_top-14], 3);
    // 배출구, 패들 자리
    translate([wall+3, yc-1, 14]) rbox([slot_w-6, 30, 30], 4);
    translate([wall+1, yc-1, 52]) cube([slot_w-2, 4, ch_top-58]);
    // 트레이 홈
    translate([2, tray_y+5, 4]) cube([mw-4, yc-tray_y-3, 10]);
    // 잔량 표시 슬롯 (위)
  }
}

module paddle(lbl) {
  translate([wall+2, yc-6, 53]) {
    color("#ff7a1a") rbox([slot_w-4, 7, ch_top-60], 3);
    color("white") translate([(slot_w-4)/2, -0.4, (ch_top-60)/2]) rotate([90,0,0])
      linear_extrude(1) text(lbl, size=11, halign="center", valign="center", font="Liberation Sans:style=Bold");
  }
}

module lid(open=0) {
  translate([0, yb, mag_top]) rotate([-open,0,0]) translate([0, ym-yb, 0]) difference() {
    color("#3a3a40") rbox([mw, yb-ym+1, 5], 2);
    translate([mw/2-3, 12, -1]) cube([6, 4*card_d+6, 8]);   // 잔량 표시 슬롯
  }
}

// 뒤 스프링 푸셔 + 잔량 표시 탭
module pusher(ncards) {
  py = (ncards)*card_d - 4;
  translate([wall+2, py, zf+2]) color("#7d8590") cube([slot_w-4, 3, 5*cell_p]);
  for (x=[wall+14, mw-wall-14], z=[zf+25, zf+80]) translate([x, py+3, z]) rotate([-90,0,0]) color("silver") spring(yb-3-(py+3), r=3, wire=0.6, turns=5);
  translate([mw/2-2.5, py, zf+2]) color("#ff7a1a") cube([5, 3, mag_top-zf+6]);
}

module unit(lbl, tint, ncards, front_cells, open=0, cards_in=true) {
  color("#2a2a2f") shell();
  paddle(lbl);
  if (cards_in) {
    for (c=[0:ncards-1]) translate([wall+6, c*card_d, zf]) card(c==0 ? front_cells : 5, tint);
    pusher(ncards);
  } else pusher(0.6);
  lid(open);
}

labels = ["1RL","3RL","5RM","7M1","9RM"];
tints  = ["#3fa9f5","#e03a3a","#f2c230","#36c2b4","#a46be0"];

// 연결된 모듈 4개
unit(labels[0], tints[0], 4, 5);
translate([mw+0.4, 0, 0])   unit(labels[1], tints[1], 3, 3);
translate([2*(mw+0.4),0,0]) { unit(labels[2], tints[2], 1, 2, open=105, cards_in=false);
  // 박스에서 꺼낸 카드 4장 통째로 투입
  for (c=[0:3]) translate([wall+6, c*card_d, mag_top+40]) card(5, tints[2]);
}
translate([3*(mw+0.4),0,0]) unit(labels[3], tints[3], 2, 4);
// 추가 모듈: 위에서 레일에 밀어 끼우는 중
translate([4*(mw+0.4)+6, 0, 70]) unit(labels[4], tints[4], 4, 5);
