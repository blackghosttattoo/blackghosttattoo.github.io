// =====================================================================
//  타투 카트리지 반자동 디스펜서 - 테스트 v1 (1라인 모듈, 출력용)
//  프린터: Bambu Lab P2S / 필라멘트: PLA
//  ※ 아래 [실측 치수]만 바꾸면 전체 부품이 다시 계산됨
//
//  part 값으로 부품 선택:
//   "lower"   하부 본체 (커팅부 + 트레이)        ← 1번 플레이트
//   "carrier" 패들 + 칼날 캐리어                 ← 1번 플레이트
//   "tongue"  받침판 (캐리어에 접착)             ← 1번 플레이트
//   "anvil"   커팅 받침(홈 있는 블록)            ← 1번 플레이트
//   "upper"   상부 매거진                        ← 2번 플레이트
//   "pusher"  카드 미는 판                       ← 2번 플레이트
//   "rod"     푸셔 가이드 봉 (2개 출력)          ← 2번 플레이트
//   "lid"     뚜껑                               ← 2번 플레이트
//   "assembly" 조립 미리보기 (출력용 아님)
//  print=true 이면 출력 방향으로 눕혀서 내보냄
// =====================================================================
part  = "assembly";
print = false;

/* ---------- [실측 치수] 사무실에서 재서 여기만 바꾸기 (mm) ---------- */
card_w  = 62;    // A. 카드 가로 (카트리지 길이 방향, 칸 5개가 쌓이는 방향과 수직)
cell_p  = 21;    // B. 칸 간격 (한 칸 중심 → 다음 칸 중심)
bub_l   = 52;    // C. 볼록부 가로 길이
bub_w   = 16;    // D. 볼록부 세로 폭
bub_h   = 10;    // E. 볼록부가 튀어나온 높이 (카드 바닥면 기준)
card_t  = 1.0;   // F. 납작한 부분 두께 (플라스틱 + 뒷면 종이)
n_cells = 5;     // 카드 1장당 칸 수
n_cards = 4;     // 1라인에 넣을 카드 장수 (4장 = 20개)

/* ---------- [출력 공차] ---------- */
clr = 0.35;      // 끼워지는 부분 여유 (빡빡하면 0.45, 헐거우면 0.25)

/* ---------- [하드웨어] ---------- */
blade_t   = 0.5;   // 커터칼날 두께 (18mm 대형 커터날 = 0.5)
blade_w   = 18;    // 커터칼날 폭
blade_len = 66;    // 커터칼날 길이 (부러뜨려서 64~67mm로 맞추기)
fil_d     = 1.75;  // 멈춤핀 = 필라멘트 조각
rod_d     = 5;     // 푸셔 가이드봉 지름

$fn = 40;

// =====================================================================
//  파생 치수 (수정 불필요)
// =====================================================================
margin  = (card_w - bub_l)/2;          // 카드 양옆 납작한 여백
card_h  = n_cells*cell_p;
card_d  = bub_h + card_t + 1.2;        // 카드 겹침 간격

wall_o  = 3;                           // 바깥벽
chan    = 6;                           // 캐리어 다리 통로
rib     = 2;                           // 통로-카드 칸막이
slot_w  = card_w + 1.6;
x_s0    = wall_o + chan + rib;
x_s1    = x_s0 + slot_w;
mw      = x_s1 + rib + chan + wall_o;  // 모듈 폭
x_c0    = x_s0 + 0.8;                  // 카드 왼쪽 끝
lip_x1  = x_c0 + max(2, margin - 1.5); // 앞 립 (카드 여백만 잡음)

// Z (높이)
z_g     = 46;                          // 받침판 윗면 = 맨 앞 카드 바닥
gap_z   = z_g + cell_p;                // 맨 아래 칸과 두번째 칸 사이 (커팅 위치)
z_pl0   = gap_z - 3;                   // 칼날판 아래
z_pl1   = gap_z + 3;                   // 칼날판 위
z_sh    = z_pl1;                       // 뒤쪽 카드 선반 높이
z_split = z_sh + 6;                    // 하부/상부 분할 높이
z_top   = z_sh + card_h + 5;
z_chc   = z_pl1 + 0.5;                 // 통로 천장
z_flr   = z_g - 3 - 0.1;               // 통로 바닥 (캐리어 다리가 얹힘)

// Y (앞 = -, 뒤 = +). 맨 앞 카드의 납작한 면 앞쪽 = 0
y_a     = card_t + clr;                // 커팅 받침(앤빌) 면
ov      = 6;                           // 칼날 관통 후 여유 이동
y_e0    = -bub_h - 1;                  // 대기 시 칼날 끝 위치
S       = (y_a + ov) - y_e0;           // 패들 스트로크
b_exp   = ov + y_a + 0.7;              // 칼날 노출 길이
tip0    = y_e0 - b_exp;                // 대기 시 쐐기 끝
valley  = cell_p - bub_w;              // 볼록부 사이 납작한 틈 높이
tip_h   = min(1.2, valley/2 - 0.5);    // 쐐기 끝 반두께
tp_len  = 18;                          // 쐐기 경사 길이
t_tf    = y_e0 - 1.5;                  // 받침판 앞끝 (캐리어 기준)
t_tr    = card_t;                      // 받침판 뒤끝
y_pk    = t_tr + S + 1.5;              // 받침판/다리 뒤쪽 공간 끝
y_fw1   = tip0 - 11;                   // 하부 앞벽 안쪽
y_fw0   = y_fw1 - 3;                   // 하부 앞벽 바깥
t_pad   = y_fw0 - S;                   // 패들 뒷면 (대기)
y_sp    = y_fw0 + 1.5;                 // 멈춤핀 위치
z_sp    = (z_g + 0.5 + z_pl0)/2;
y_ins1  = y_pk + 10;                   // 앤빌 블록 뒤끝
y_bin   = (n_cards-1)*card_d + card_t + 3 + 6 + 20;  // 뒤벽 안쪽
y_back  = y_bin + 3;
y_bf    = -bub_h - 1.5;                // 볼록부 앞쪽 공간
y_uf    = y_bf - 3;                    // 상부 앞벽 바깥
y_tray  = -105;

// 배출 경사로: z = 6 + (y+50)*k
ch_k    = (z_g - 12 - 6)/(2 + 50);
function chz(y) = 6 + (y + 50)*ch_k;

// 푸셔 가이드봉 위치 (x, z)
rods = [[mw/2-18, z_sh+30], [mw/2+18, z_sh+card_h-30]];
rod_len = y_back + 0.5 - (y_a + 1 + 3);

echo(str("모듈 크기 (폭x깊이x높이) = ", mw, " x ", y_back - y_tray, " x ", z_top+3));
if (valley < 3.4) echo("⚠ 칸 사이 틈이 너무 좁음: 쐐기/칼날 설계 재검토 필요");
echo(str("패들 스트로크 = ", S, " mm, 칼날 노출 = ", b_exp, " mm"));

// =====================================================================
//  공통
// =====================================================================
module box(x0,x1,y0,y1,z0,z1) { translate([x0,y0,z0]) cube([x1-x0, y1-y0, z1-z0]); }
module rbox(x0,x1,y0,y1,z0,z1,r=2) {
  hull() for (x=[x0+r,x1-r], y=[y0+r,y1-r]) translate([x,y,z0]) cylinder(r=r, h=z1-z0, $fn=20);
}
module dt_male(z0,z1) {
  for (y=[42, y_back-12]) translate([mw, y, z0])
    linear_extrude(z1-z0) polygon([[-0.01,-2.5],[3,-4],[3,4],[-0.01,2.5]]);
}
module dt_female(z0,z1) {
  c = clr;
  for (y=[42, y_back-12]) translate([0, y, z0-1])
    linear_extrude(z1-z0+2) polygon([[-1,-2.5-c],[-0.01,-2.5-c],[3+c,-4-c],[3+c,4+c],[-0.01,2.5+c],[-1,2.5+c]]);
}
module chute_solid(x0,x1) {   // 경사로 아래 꽉 찬 부분
  translate([x0,0,0]) rotate([90,0,90]) linear_extrude(x1-x0)
    polygon([[y_tray-5,0],[10,0],[10,chz(10)],[-50,chz(-50)],[-50,3],[y_tray-5,3]]);
}

// =====================================================================
//  하부 본체
// =====================================================================
module lower() {
  difference() {
    union() {
      box(0, mw, y_fw0, y_back, 0, z_split);
      box(0, mw, y_tray, y_fw0+1, 0, 3);                      // 트레이 바닥
      box(0, mw, y_tray, y_tray+2.5, 0, 12);                  // 트레이 앞턱
      dt_male(0, z_split);
    }
    dt_female(0, z_split);

    // 앞쪽 카드/낙하 공간 (경사로 위)
    difference() { box(x_s0, x_s1, y_fw1, y_a, 3, z_split+1); chute_solid(x_s0-1, x_s1+1); }
    // 배출구 (앞벽 아래)
    difference() { box(x_s0, x_s1, y_fw0-1, y_fw1+1, 3, z_g-6); chute_solid(x_s0-1, x_s1+1); }
    // 선반 위 카드 공간
    box(x_s0, x_s1, y_a, y_bin, z_sh, z_split+1);
    // 앤빌 블록 자리
    box(x_s0, x_s1, y_a-0.01, y_ins1, z_g+0.4, z_sh+0.01);
    // 받침판 이동 공간 (앤빌 아래)
    box(wall_o, mw-wall_o, y_a-0.01, y_pk, z_flr, z_g+0.4);
    // 칸막이 아래 개구부 (받침판 연결부 통과)
    for (x=[x_s0-rib, x_s1]) box(x, x+rib, y_fw0-1, y_pk, z_flr, z_g+0.5);
    // 캐리어 다리 통로 (앞으로 열림)
    for (x=[wall_o, x_s1+rib]) {
      box(x, x+chan, y_fw0-1, y_pk, z_flr, z_chc);
      box(x, x+chan, y_pk-0.01, y_pk+12, z_flr, z_flr+7.5);  // 복귀 스프링 자리
    }
    // 칼날판 통과 공간
    box(wall_o, mw-wall_o, y_fw0-1, 8, z_pl0-0.5, z_chc);
    // 멈춤핀 구멍 (양옆, 필라멘트)
    for (side=[0,1]) translate([side==0 ? -1 : mw-wall_o-rib-chan-1, y_sp, z_sp])
      rotate([0,90,0]) cylinder(d=fil_d+0.15, h=wall_o+chan+rib+1, $fn=16);
  }
  // 상부 결합 핀
  for (p=[[5.5,8],[mw-5.5,8],[5.5,y_back-6],[mw-5.5,y_back-6]])
    translate([p[0],p[1],z_split-0.01]) cylinder(d=4, h=5, $fn=24);
  // 앞 립 (카드 양옆 여백을 앞에서 잡아줌, 칼날판 지나가는 높이는 비움)
  for (m=[0,1]) mirror_x(m) {
    box(x_s0-0.01, lip_x1, -3, -clr, z_g+0.6, z_pl0-0.5);
    box(x_s0-0.01, lip_x1, -3, -clr, z_chc, z_split);
  }
}
module mirror_x(m) { if (m==0) children(); else translate([mw,0,0]) mirror([1,0,0]) children(); }

// =====================================================================
//  캐리어 (패들 + 칼날판 + 다리)   좌표 = 대기 위치 기준
// =====================================================================
module carrier() {
  difference() {
    union() {
      // 패들 (손등으로 누르는 판)
      rbox(0.5, mw-0.5, t_pad-5, t_pad, z_g-16, z_g+46, 2);
      // 칼날판: 뒤로 갈수록 얇아지는 쐐기
      translate([wall_o+clr, 0, 0]) rotate([90,0,90]) linear_extrude(mw-2*wall_o-2*clr)
        polygon([[t_pad-0.1, z_pl0], [tip0-tp_len, z_pl0], [tip0, gap_z-tip_h],
                 [tip0, gap_z+tip_h], [tip0-tp_len, z_pl1], [t_pad-0.1, z_pl1]]);
      // 다리 (양옆 통로 안)
      for (x=[wall_o+clr, x_s1+rib+clr]) box(x, x+chan-2*clr, t_pad-0.1, t_tr, z_g-3, z_pl1);
      // 받침판 얹는 턱 + 핀
      for (m=[0,1]) mirror_x(m) {
        box(wall_o+chan-clr-0.5, x_s0+6-0.2, t_tf, t_tr, z_g-3, z_g-1.5);
        translate([x_s0+2, (t_tf+t_tr)/2, z_g-1.6]) cylinder(d=2, h=1.4, $fn=16);
      }
    }
    // 칼날 꽂는 홈
    translate([wall_o-1, tip0-blade_w+b_exp-0.5, gap_z-(blade_t+0.2)/2]) cube([mw-2*wall_o+2, blade_w-b_exp+0.6, blade_t+0.2]);
    // 멈춤핀이 지나가는 긴 홈
    for (x=[wall_o-1, x_s1+rib-1]) translate([x, y_sp-0.975-S-0.6, z_sp-1.1]) cube([chan+2, S+0.6+2*0.975, 2.2]);
  }
}

// 받침판 (맨 앞 카드가 서 있는 판, 누르면 뒤로 빠짐)
module tongue() {
  difference() {
    union() {
      box(x_s0+6, x_s1-6, t_tf, t_tr, z_g-3, z_g);
      for (m=[0,1]) mirror_x(m) box(x_s0-rib+0.4, x_s0+6+0.01, t_tf, t_tr, z_g-1.5+0.15, z_g);
    }
    for (m=[0,1]) mirror_x(m) translate([x_s0+2, (t_tf+t_tr)/2, z_g-2]) cylinder(d=2.3, h=3, $fn=16);
  }
}

// 앤빌 (칼날이 카드를 관통해 들어가는 홈이 있는 블록)
module anvil() {
  difference() {
    box(x_s0+clr, x_s1-clr, y_a, y_ins1-clr, z_g+0.4+0.15, z_sh);
    box(x_s0, x_s1, y_a-1, y_a+ov+2, gap_z-0.5, gap_z+0.5);
  }
}

// =====================================================================
//  상부 매거진
// =====================================================================
module upper() {
  difference() {
    union() {
      box(0, mw, y_uf, y_back, z_split, z_top);
      dt_male(z_split, z_top);
    }
    dt_female(z_split, z_top);
    box(x_s0, x_s1, y_bf, y_bin, z_split-1, z_top+1);
    // 잔량 확인 창
    box(lip_x1+1.5, x_s1-(lip_x1-x_s0)-1.5, y_uf-1, y_bf+1, z_split+10, z_g+card_h-2);
    // 푸셔 가이드봉 구멍
    for (r=rods) translate([r[0], y_bin-1, r[1]]) rotate([-90,0,0]) cylinder(d=rod_d+0.8, h=5, $fn=24);
    // 결합 핀 구멍
    for (p=[[5.5,8],[mw-5.5,8],[5.5,y_back-6],[mw-5.5,y_back-6]])
      translate([p[0],p[1],z_split-1]) cylinder(d=4+2*clr, h=6.5, $fn=24);
  }
  // 앞 립 (위쪽)
  for (m=[0,1]) mirror_x(m) box(x_s0-0.01, lip_x1, y_bf-0.01, -clr, z_split, z_top);
}

module pusher() {
  difference() {
    union() {
      box(x_s0+0.6, x_s1-0.6, 0, 3, z_sh+0.5, z_sh+card_h-1);
      for (r=rods) translate([r[0], 3-0.01, r[1]]) rotate([-90,0,0]) cylinder(d=10, h=6, $fn=32);
    }
    for (r=rods) translate([r[0], -1, r[1]]) rotate([-90,0,0]) cylinder(d=rod_d+0.1, h=11, $fn=24);
  }
}

rod_af = rod_d*cos(22.5);   // 8각봉 맞변 거리
module rod() {   // 축 = +Z (미리보기용)
  rotate([0,0,22.5]) cylinder(d=rod_d, h=rod_len, $fn=8);
  translate([-rod_af/2, -4.5, rod_len-0.01]) cube([7, 9, 2]);
}
module rod_print() {  // 눕혀서 평평한 면이 바닥에 닿게
  translate([0,0,rod_af/2]) rotate([0,90,0]) rotate([0,0,22.5]) cylinder(d=rod_d, h=rod_len, $fn=8);
  translate([rod_len-0.01, -4.5, 0]) cube([2, 9, 7]);
}

module lid() {
  box(0, mw, y_uf, y_back, 0, 3);
  difference() {
    box(x_s0+0.5, x_s1-0.5, y_bf+0.5, y_bin-0.5, -4, 0.01);
    box(x_s0+2.1, x_s1-2.1, y_bf+2.1, y_bin-2.1, -5, 1);
  }
}

// =====================================================================
//  카드 (미리보기용)
// =====================================================================
module card_preview(n) {
  for (k=[0:n-1]) translate([x_c0, 0, k*cell_p]) {
    cube([card_w, card_t, cell_p-0.4]);
    translate([margin, -bub_h, (cell_p-bub_w)/2]) cube([bub_l, bub_h, bub_w]);
  }
}

// =====================================================================
//  출력 / 미리보기
module cut(c) { difference() { color(c) children(); color(c) translate([mw/2,-300,-10]) cube([200,600,400]); } }
// =====================================================================
if (part=="assembly") {
  color("#2b2b30") lower();
  color("#3a3a42") upper();
  color("#ff7a1a") carrier();
  color("#ffb070") tongue();
  color("#7a8590") anvil();
  color("silver") translate([(mw-blade_len)/2, tip0-blade_w+b_exp, gap_z-blade_t/2]) cube([blade_len, blade_w, blade_t]);
  translate([0,0,z_g]) card_preview(n_cells);
  for (c=[1:n_cards-1]) translate([0, c*card_d, z_sh]) card_preview(n_cells);
  color("#8a8f99") translate([0, (n_cards-1)*card_d + card_t + 0.3, 0]) pusher();
  color("#3a3a42") translate([0,0,z_top]) lid();
}
else if (part=="section" || part=="section_pressed") {
  sp = part=="section_pressed" ? S : 0;
  cut("#3b3b42") lower();
  cut("#55555f") upper();
  translate([0,sp,0]) { cut("#ff7a1a") carrier(); cut("#ffc890") tongue();
    cut("#e8e8e8") translate([(mw-blade_len)/2, tip0-blade_w+b_exp, gap_z-blade_t/2]) cube([blade_len, blade_w, blade_t]); }
  cut("#4f86c6") anvil();
  cut("#9ad0ff") translate([0,0,z_g]) card_preview(n_cells);
  for (c=[1:n_cards-1]) cut("#9ad0ff") translate([0, c*card_d, z_sh]) card_preview(n_cells);
  cut("#a0a6b0") translate([0, (n_cards-1)*card_d + card_t + 0.3, 0]) pusher();
}
else if (part=="lower")   lower();
else if (part=="carrier") { if (print) rotate([90,0,0]) translate([0,-(t_pad-5),0]) carrier(); else carrier(); }
else if (part=="tongue")  { if (print) translate([0,0,z_g]) mirror([0,0,1]) tongue(); else tongue(); }
else if (part=="anvil")   { if (print) rotate([-90,0,0]) translate([0,-y_ins1+clr,0]) anvil(); else anvil(); }
else if (part=="upper")   { if (print) translate([0,0,-z_split]) upper(); else upper(); }
else if (part=="pusher")  { if (print) rotate([90,0,0]) pusher(); else pusher(); }
else if (part=="rod")     { if (print) rod_print(); else rod(); }
else if (part=="lid")     { if (print) translate([0,0,3]) mirror([0,0,1]) lid(); else lid(); }
