; RUN: opt -S -dxil-translate-metadata %s | FileCheck %s

; DXC always emits !llvm.ident.

target triple = "dxil-pc-shadermodel6.6-compute"

; CHECK-DAG: !llvm.ident = !{![[#IDENT:]]}
; CHECK-DAG: ![[#IDENT]] = !{!"llvm ({{.*}})"}

; CHECK-DAG: !dx.shaderModel = !{![[#SM:]]}
; CHECK-DAG: ![[#SM]] = !{!"cs", i32 6, i32 6}

define void @CSMain() #0 {
  ret void
}

attributes #0 = { "hlsl.numthreads"="1,1,1" "hlsl.shader"="compute" }
