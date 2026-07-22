;; Verify that byte types are encoded as integer types in DXIL bitcode.
; RUN: llc --filetype=obj %s --stop-after=dxil-write-bitcode -o %t
; RUN: llvm-bcanalyzer --dump %t | FileCheck %s

target triple = "dxil--shadermodel6.5-library"

;; Since bitcode defines types up front and then refers back to them using
;; their indices, we unfortunately need to hardcode the entire type block here,
;; which means this test may be brittle.

;; See https://llvm.org/docs/BitCodeFormat.html for help interpreting below.
;;
;; Opaque pointers are lowered to i8* (not a reserved opaque struct). The type
;; table is prefixed with void to match DXC's empty-module layout.
;
; CHECK:      <TYPE_BLOCK_ID
; CHECK-NEXT:   <NUMENTRY op0=21/>
; CHECK-NEXT:   <VOID/>
;; 1: i8 (byte types lower to integer)
; CHECK-NEXT:   <INTEGER op0=8/>
;; 2: [32 x i8]
; CHECK-NEXT:   <ARRAY {{.*}} op0=32 op1=1/>
;; 3: [32 x i8]*
; CHECK-NEXT:   <POINTER {{.*}} op0=2 op1=0/>
;; 4-10: The return and operand types of @bytes, except `i8`,
; CHECK-NEXT:   <INTEGER op0=1/>
; CHECK-NEXT:   <INTEGER op0=3/>
; CHECK-NEXT:   <INTEGER op0=5/>
; CHECK-NEXT:   <INTEGER op0=16/>
; CHECK-NEXT:   <INTEGER op0=32/>
; CHECK-NEXT:   <INTEGER op0=64/>
; CHECK-NEXT:   <INTEGER op0=128/>
;; 11: <8 x i5>
; CHECK-NEXT:   <VECTOR op0=8 op1=6/>
;; 12: <2 x i64>
; CHECK-NEXT:   <VECTOR op0=2 op1=9/>
;; 13: void(i1, i3, i5, i8, i16, i32, i64, i128, <8 x i5>, <2 x i64>)
; CHECK-NEXT:   <FUNCTION {{.*}} op0=0 op1=0 op2=4 op3=5 op4=6 op5=1 op6=7 op7=8 op8=9 op9=10 op10=11 op11=12/>
; CHECK-NEXT:   <POINTER {{.*}} op0=13 op1=0/>
;; 15: b32()
; CHECK-NEXT:   <FUNCTION {{.*}} op0=0 op1=8/>
; CHECK-NEXT:   <POINTER {{.*}} op0=15 op1=0/>
;; 17: b128()
; CHECK-NEXT:   <FUNCTION {{.*}} op0=0 op1=10/>
; CHECK-NEXT:   <POINTER {{.*}} op0=17 op1=0/>
; CHECK-NEXT:   <METADATA/>
; CHECK-NEXT:   <INTEGER op0=32/>
; CHECK-NEXT: </TYPE_BLOCK_ID>

;; Sanity check that the globals are coherently ordered.
; CHECK:      <GLOBALVAR {{.*}} op0=2
; CHECK-NEXT: <FUNCTION op0=13
; CHECK-NEXT: <FUNCTION op0=15
; CHECK-NEXT: <FUNCTION op0=17

; CHECK:      <VALUE_SYMTAB
; CHECK-NEXT:   <ENTRY {{.*}} op0=0 {{.*}}/> record string = 'a'
; CHECK-NEXT:   <ENTRY {{.*}} op0=1 {{.*}}/> record string = 'bytes'
; CHECK-NEXT:   <ENTRY {{.*}} op0=3 {{.*}}/> record string = 'constant128'
; CHECK-NEXT:   <ENTRY {{.*}} op0=2 {{.*}}/> record string = 'constant32'
; CHECK-NEXT: </VALUE_SYMTAB>

@a = common global [32 x b8] zeroinitializer, align 1

define void @bytes(b1 %a, b3 %b, b5 %c, b8 %d, b16 %e, b32 %f, b64 %g, b128 %h, <8 x b5> %i, <2 x b64> %j) {
  ; CHECK: <FUNCTION_BLOCK
  ret void
}

define b32 @constant32() {
  ; CHECK: <FUNCTION_BLOCK
  ; CHECK:      <CONSTANTS_BLOCK
  ; CHECK-NEXT:   <SETTYPE {{.*}} op0=8/>
  ;; The value here is signed variable-length encoded, so the value is doubled
  ; CHECK-NEXT:   <INTEGER {{.*}} op0=246/>
  ret b32 123
}

define b128 @constant128() {
  ; CHECK: <FUNCTION_BLOCK
  ; CHECK:      <CONSTANTS_BLOCK
  ; CHECK-NEXT:   <SETTYPE {{.*}} op0=10/>
  ;; The value here is signed variable-length encoded, so the value is doubled
  ; CHECK-NEXT:   <WIDE_INTEGER op0=24682468/>
  ret b128 12341234
}
