// -*- tablegen-ts -*-
include "abc"
// Class
class Foo {
  int Bar = 5;
  int Baz = Bar;
}
class WMMA_REGS<string Geom, string Frag, string PtxEltType> {
  list<LLVMType> regs = !cond(
    !eq(gft,"m8n8k4:a:f16") : !listsplat(llvm_v2f16_ty, 2),
  );
}
multiclass SystemZUnaryBHFG<string name> : SystemZUnaryBHF<name> {
  def g : SystemZUnary<name#"g", llvm_v2i64_ty>;
}
class PersonName<string name> {
  assert !le(!size(name), 32), "person name is too long: " # name;
  string Name = name;
}
class Person<string name, int age> : PersonName<name> {
  assert !and(!ge(age, 1), !le(age, 120)), "person age is invalid: " # age;
  int Age = age;
}
// Field
class AArch64Inst<Format f, string cstr> : Instruction {
  field bits<32> Inst; // Instruction encoding.
}
// Def
def Imm;
def rec1 : A<(ops rec1)>;
def ADD32rr {   // Instruction X86Inst I
  string Namespace = "X86";
  dag OutOperandList = (outs GR32:$dst);
  dag InOperandList = (ins GR32:$src1, GR32:$src2);
  string AsmString = "add{l}\t{$src2, $dst|$dst, $src2}";
  list<dag> Pattern = [(set GR32:$dst, (add GR32:$src1, GR32:$src2))];
  list<Register> Uses = [];
  list<Register> Defs = [EFLAGS];
  list<Predicate> Predicates = [];
  bit hasSideEffects = 0;
  InstrItinClass Itinerary = NoItinerary;
  string DisableEncoding = "";
  bits<8> Opcode = { 0, 0, 0, 0, 0, 0, 0, 1 };
  Format Form = MRMDestReg;
  ImmType ImmT = NoImm;
  FPFormat FPForm = ?;
}
defvar i = !add(i, 1);

// Let
let isTerminator = true, isReturn = true, isBarrier = true, hasCtrlDep = true in
  def RET : I<0xC3, RawFrm, (outs), (ins), "ret", [(X86retflag 0)]>;
let isCall = true in
  // All calls clobber the non-callee saved registers...
  let Defs = [EAX, ECX, EDX, FP0, FP1, FP2, FP3, FP4, FP5, FP6, ST0,
    MM0, MM1, MM2, MM3, MM4, MM5, MM6, MM7, XMM0, XMM1, XMM2,
    XMM3, XMM4, XMM5, XMM6, XMM7, EFLAGS] in {
    def CALLpcrel32 : Ii32<0xE8, RawFrm, (outs), (ins i32imm:$dst, variable_ops),
      "call\t${dst:call}", []>;
    def CALL32r     : I<0xFF, MRM2r, (outs), (ins GR32:$dst, variable_ops),
      "call\t{*}$dst", [(X86call GR32:$dst)]>;
    def CALL32m     : I<0xFF, MRM2m, (outs), (ins i32mem:$dst, variable_ops),
      "call\t{*}$dst", []>;
  }
def OMP_Tile : Directive<"tile"> {
  let allowedOnceClauses = [
    VersionedClause<OMPC_Sizes, 51>,
  ];
}
// Foreach
foreach i = [0, 1, 2, 3] in {
  def R#i : Register<>;
  def F#i : Register<>;
}
