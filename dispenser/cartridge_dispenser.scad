// 타투 카트리지 블리스터 디스펜서 - 컨셉 모델 (대략 치수, mm)
// 블리스터 카드(5칸)를 세로로 세워 넣고, 맨 아래 칸을 앞으로 꺾어 분리
// view: 0 = 외관, 1 = 측면 단면, 2 = 출구 확대
view = 0;

// ---- 블리스터 카드 가정 치수 (실측 후 교체) ----
cell_p   = 21;   // 칸 간격 (브랜드마다 다름 → 걸쇠가 자동으로 틈을 찾음)
bub_w    = 16;   // 볼록부 높이 방향 폭
bub_h    = 10;   // 볼록부 돌출 높이
card_w   = 62;   // 카드 폭 (카트리지 길이 방향, 대응 55~70)
bub_l    = 52;   // 볼록부 길이
card_t   = 0.6;
n_cells  = 5;

// ---- 본체 ----
nslots = 4;
slot_w = 74;     // 슬롯 폭 (스프링 가이드로 55~70 카드 대응)
wall   = 4;
z0     = 46;     // 본체 아래면 높이 (아래로 한 칸 노출)
body_h = n_cells*cell_p + 10;
yf     = -15;    // 앞면
yb     = 5;      // 뒷면
base_d = 70;

function sx(i) = wall + i*(slot_w+wall);
total_w = nslots*slot_w + (nslots+1)*wall;

$fn = 36;

module rbox(s, r=1.5) {
  hull() for (x=[r,s[0]-r], y=[r,s[1]-r], z=[r,s[2]-r]) translate([x,y,z]) sphere(r, $fn=12);
}
module spring(h, r=3, wire=0.6, turns=5) {
  linear_extrude(height=h, twist=-360*turns, slices=turns*24) translate([r,0]) circle(wire, $fn=10);
}

// ---------- 블리스터 한 칸 (평면 XZ, 볼록부는 -Y) ----------
module cell(tint="#3fa9f5") {
  // 평평한 카드(플랜지) + 종이 뒷면
  color([0.93,0.95,0.97,0.9]) translate([0, 0, 0.6]) cube([card_w, card_t, cell_p-1.2]);
  color("#f4f4f4") translate([0, card_t, 0.6]) cube([card_w, 0.5, cell_p-1.2]);
  // 볼록부 테두리 (투명 블리스터 윤곽만 표시)
  color([0.9,0.95,1.0]) translate([(card_w-bub_l)/2, -0.2, cell_p/2]) difference() {
    hull() for (x=[bub_w/2, bub_l-bub_w/2]) translate([x,0,0]) rotate([90,0,0]) cylinder(d=bub_w+1.4, h=0.6);
    hull() for (x=[bub_w/2, bub_l-bub_w/2]) translate([x,0.1,0]) rotate([90,0,0]) cylinder(d=bub_w-0.2, h=1);
  }
  // 카트리지
  translate([(card_w-bub_l)/2+5, -bub_h*0.55, cell_p/2]) rotate([0,90,0]) {
    color("#d8dde3") cylinder(d=9, h=24);
    color("#9aa3ad") translate([0,0,24]) cylinder(d1=9, d2=4, h=8);
    color("#555") translate([0,0,32]) cylinder(d=1, h=8);
    color(tint) translate([0,0,-6]) cylinder(d=6.5, h=6);
  }
}
// 칸 사이 틈 표시 (절취선)
module perf() { color("#9ab") for (x=[2:4:card_w-2]) translate([x, -0.05, cell_p-0.6]) cube([2, card_t+0.1, 1.2]); }

module card(i, count=5, tear=0, tint="#3fa9f5") {
  x = sx(i) + 5;
  for (k=[0:count-1]) {
    zc = z0 - cell_p + k*cell_p;
    if (k==0 && tear!=0)
      translate([x, 0, z0]) rotate([tear,0,0]) translate([0,0,-cell_p]) cell(tint);
    else translate([x, 0, zc]) { cell(tint); if (k<count-1) perf(); }
  }
}

// ---------- 본체 ----------
module body() {
  difference() {
    union() {
      // 바닥 받침
      translate([0, -base_d+10, 0]) rbox([total_w, base_d+2, 7], 3);
      // 양 끝 옆판 (바닥까지)
      for (x=[0, total_w-wall]) translate([x, yf, 0]) cube([wall, yb-yf, z0+body_h]);
      // 상부 본체
      translate([0, yf, z0]) cube([total_w, yb-yf, body_h]);
      // 뒤판 (아래까지 내려와 지지)
      translate([0, 1.5, 0]) cube([total_w, yb-1.5, z0]);
    }
    for (i=[0:nslots-1]) {
      // 카드 슬롯 (위에서 투입, 아래로 관통)
      translate([sx(i), yf+3, z0-1]) cube([slot_w, 1.5-(yf+3), body_h+2]);
      // 앞 창 (볼록부 노출, 가장자리 립이 카드 고정)
      translate([sx(i)+9, yf-1, z0-1]) cube([slot_w-18, 6, body_h+2]);
    }
    // 바닥 받침 위 홈 (분리된 카트리지 받는 트레이)
    translate([wall+2, -base_d+16, 4]) rbox([total_w-2*wall-4, base_d-20, 10], 3);
  }
}

// 스프링 폭 가이드 (파랑)
module guide(i) {
  translate([sx(i)+slot_w-6, yf+4, z0+2]) color("#2f6fd6") cube([1.6, 1.5-(yf+4)-0.5, body_h-4]);
  for (z=[z0+20, z0+body_h-25]) translate([sx(i)+slot_w, -4, z]) rotate([0,-90,0]) color("silver") spring(4.4, r=2.2, wire=0.45, turns=4);
}

// 자동 틈 찾기 걸쇠 바 (주황) - 맨 아래 칸 위 틈에 스프링으로 눌려 들어감
module latch(i) {
  translate([sx(i)+1, 0, z0]) {
    color("#ff7a1a") {
      // 바: 단면이 쐐기, 끝이 틈(플랜지)에 닿음
      rotate([0,90,0]) linear_extrude(slot_w-2)
        polygon([[-1.2,-0.8],[1.2,-0.8],[3.5,-11],[3.5,-15],[-3.5,-15],[-3.5,-11]]);
      // 피벗 암
      for (x=[0, slot_w-5]) translate([x, -15, -3.5]) cube([3, 4, 12]);
    }
    color("#ddd") translate([3, -1.6, -0.2]) cube([slot_w-8, 1.2, 0.4]); // 교체식 톱날 팁
    for (x=[12, slot_w-16]) translate([x, -16, 3.5]) rotate([90,0,0]) color("silver") spring(4, r=1.8, wire=0.4, turns=4);
  }
}

// 위 누름판
module weight(i, count) {
  translate([sx(i)+3, yf+3.5, z0 - cell_p + count*cell_p + 1]) color("#777") rbox([slot_w-10, 1.5-(yf+3.5)-0.5, 8], 1.5);
}

module slot_parts(i, cnt, tear, tint) { card(i, cnt, tear, tint); latch(i); guide(i); weight(i, cnt); }

tints = ["#3fa9f5", "#e03a3a", "#36c2b4", "#f0f0f0"];
counts = [5, 3, 5, 4];

if (view==0) {
  color("#2a2a2f") body();
  for (i=[0:nslots-1]) slot_parts(i, counts[i], i==0 ? -38 : 0, tints[i]);
}
if (view==1 || view==2) {
  // 첫 슬롯 중앙 단면
  cutx = sx(0) + slot_w/2;
  difference() { color("#2a2a2f") body(); translate([cutx, -200, -1]) cube([400, 400, 400]); }
  intersection() {
    union() { card(0, 5, view==2 ? -38 : 0, tints[0]); latch(0); weight(0,5); }
    translate([-1, -200, -1]) cube([cutx+1, 400, 400]);
  }
}
