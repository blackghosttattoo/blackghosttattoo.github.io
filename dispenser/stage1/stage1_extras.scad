// =====================================================================
//  1단계 대체 부품 (하드웨어 대신 출력)
//   "blade"  : PLA 테스트 날 (칼날 홈에 끼움, 동작·절취선 테스트용)
//   "pin"    : 조립 핀 (필라멘트 조각 대신, 1.9mm 구멍용)
//   "all"    : 한 판 배치 (날 1 + 핀 8)
//   ※ 복귀 스프링은 PLA로 불가 (32mm 공간에서 24mm 눌려야 함) → 볼펜 스프링 사용 또는 손으로 복귀
// =====================================================================
include <stage1_lib.scad>   // stage1.scad 의 "if (part==" 이전 부분을 stage1_lib.scad 로 저장해서 사용
part = "all";

// ---- 테스트 날 ----
bd_t = 0.6;                     // 홈 0.7mm에 맞춤
module blade_dummy() {          // 출력 방향 그대로 (바닥에 눕힘)
  L = blade_len; W = blade_w;
  hull() {
    cube([L, W-2.5, bd_t]);
    translate([0, W-0.01, 0]) cube([L, 0.01, 0.2]);    // 날 끝 쪽으로 얇아짐
  }
}

// ---- 조립 핀 ----
pin_d = 1.6;  pin_l = 8;        // 구멍 1.9mm
module pin() {                  // 눕혀서 출력, 바닥 평평
  af = pin_d*cos(22.5);
  translate([0,0,af/2]) rotate([0,90,0]) rotate([0,0,22.5]) cylinder(d=pin_d, h=pin_l, $fn=8);
  translate([-1.6, -2.5, 0]) cube([1.6, 5, 2.2]);       // 머리 (손잡이)
}

if (part=="blade")  blade_dummy();
if (part=="pin")    pin();
if (part=="all") {
  translate([10, 10, 0]) blade_dummy();
  for (i=[0:7]) translate([15 + i*12, 45, 0]) rotate([0,0,90]) pin();
}
