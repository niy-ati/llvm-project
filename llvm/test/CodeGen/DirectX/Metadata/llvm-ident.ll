; RUN: opt -S -dxil-translate-metadata %s | FileCheck %s

; Frontends (Clang/DXC/LDC) must emit !llvm.ident. This pass preserves it.

target triple = "dxil-pc-shadermodel6.6-compute"

!llvm.ident = !{!0}
!0 = !{!"frontend test"}

; CHECK-DAG: !llvm.ident = !{![[#IDENT:]]}
; CHECK-DAG: ![[#IDENT]] = !{!"frontend test"}

; CHECK-DAG: !dx.shaderModel = !{![[#SM:]]}
; CHECK-DAG: ![[#SM]] = !{!"cs", i32 6, i32 6}

define void @CSMain() #0 {
  ret void
}

attributes #0 = { "hlsl.numthreads"="1,1,1" "hlsl.shader"="compute" }
