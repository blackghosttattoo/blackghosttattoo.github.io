// 타투 카트리지 반자동 디스펜서 - 컨셉 모델 (대략 치수, mm)
// 위에서 카드 통째로 투입 → 패들 누르면 V칼날이 맨 아래 칸을 잘라 앞 트레이로 배출
// 실측 후 아래 치수만 바꾸면 됨

// ---- 블리스터 카드 가정 치수 ----
cell_p  = 21;   // 칸 간격 (V칼날이 골짜기를 스스로 찾으므로 브랜드별 조절 불필요)
bub_w   = 16;
bub_h   = 10;
card_w  = 62;
bub_l   = 52;
card_t  = 0.6;

// ---- 본체 ----
nslots  = 4;
slot_w  = 74;
wall    = 4;
zf      = 80;               // 맨 아래 칸이 얹히는 받침(게이트) 높이
cap_cells = 10;             // 슬롯당 카드 2장
mag_top = zf + cap_cells*cell_p + 12;
ch_top  = zf + cell_p + 22; // 커팅 챔버 윗면
yb      = 8;                // 뒷면
ym      = -18;              // 매거진 앞면
yc      = -46;              // 커팅 챔버 앞면
tray_y  = -112;

function sx(i) = wall + i*(slot_w+wall);
total_w = nslots*slot_w + (nslots+1)*wall;
labels  = ["1RL", "3RL", "7M1", "9RM"];
counts  = [10, 6, 9, 4];
tints   = ["#3fa9f5", "#e03a3a", "#36c2b4", "#f2c230"];

$fn = 36;

module rbox(s, r=1.5) {
  hull() for (x=[r,s[0]-r], y=[r,s[1]-r], z=[r,s[2]-r]) translate([x,y,z]) sphere(r, $fn=12);
}

// 블리스터 한 칸: 카드 평면 XZ, 볼록부 -Y, 원점 = 칸 왼쪽 아래
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

module stack(i) {
  for (k=[0:counts[i]-1]) translate([sx(i)+6, 0, zf + k*cell_p]) { cell(tints[i]); if (k<counts[i]-1) perf(); }
}

module housing() {
  difference() {
    union() {
      // 바닥판 + 트레이
      translate([0, tray_y, 0]) rbox([total_w, yb-tray_y, 8], 4);
      // 커팅 챔버 (아래 넓은 부분)
      translate([0, yc, 8]) rbox([total_w, yb-yc, ch_top-8], 3);
      // 매거진 (위쪽 슬롯 타워)
      translate([0, ym, 8]) cube([total_w, yb-ym, mag_top-8]);
    }
    for (i=[0:nslots-1]) {
      // 카드 슬롯
      translate([sx(i), ym+3, zf]) cube([slot_w, yb-3-(ym+3), mag_top]);
      // 잔량 확인 창
      translate([sx(i)+10, ym-1, ch_top+6]) rbox([slot_w-20, 8, mag_top-ch_top-18], 3);
      // 배출구
      translate([sx(i)+5, yc-1, 14]) rbox([slot_w-10, 30, 30], 4);
      // 패들 자리
      translate([sx(i)+3, yc-1, 52]) cube([slot_w-6, 4, ch_top-58]);
    }
    // 트레이 홈
    translate([wall, tray_y+6, 4]) rbox([total_w-2*wall, yc-tray_y-4, 10], 4);
  }
}

module paddle(i) {
  translate([sx(i)+4, yc-6, 53]) {
    color("#ff7a1a") rbox([slot_w-8, 7, ch_top-60], 3);
    color("white") translate([(slot_w-8)/2, -0.4, (ch_top-60)/2]) rotate([90,0,0])
      linear_extrude(1) text(labels[i], size=11, halign="center", valign="center", font="Liberation Sans:style=Bold");
  }
}

// 반쯤 열린 뚜껑
module lid() {
  translate([0, yb, mag_top]) rotate([-28,0,0]) translate([0, ym-yb, 0])
    color("#3a3a40") rbox([total_w, yb-ym+2, 5], 2);
}

// 투입 중인 카드 (4번 슬롯 위)
module loading_card() {
  translate([sx(3)+6, 0, mag_top+4]) for (k=[0:4]) translate([0,0,k*cell_p]) { cell(tints[3]); if (k<4) perf(); }
}

// 트레이에 나온 카트리지 1개 (눕혀진 상태)
module dispensed() {
  translate([sx(0)+10, -62, 9.5]) rotate([0,0,-12]) rotate([-90,0,0]) rotate([0,0,0]) translate([0,0,-cell_p]) cell(tints[0]);
}

color("#2a2a2f") housing();
for (i=[0:nslots-1]) { stack(i); paddle(i); }
lid();
loading_card();
dispensed();
