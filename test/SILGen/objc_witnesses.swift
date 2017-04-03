// RUN: %target-swift-frontend -emit-silgen -sdk %S/Inputs -I %S/Inputs -enable-source-import %s | %FileCheck %s

// REQUIRES: objc_interop

import Foundation
import gizmo

protocol Fooable {
  func foo() -> String!
}

// Witnesses Fooable.foo with the original ObjC-imported -foo method .
extension Foo: Fooable {}

class Phoûx : NSObject, Fooable {
  @objc func foo() -> String! {
    return "phoûx!"
  }
}

// witness for Foo.foo uses the foreign-to-native thunk:
// CHECK-LABEL: sil hidden [transparent] [thunk] @_TTWCSo3Foo14objc_witnesses7FooableS0_FS1_3foo
// CHECK:         function_ref @_TTOFCSo3Foo3foo

// *NOTE* We have an extra copy here for the time being right
// now. This will change once we teach SILGen how to not emit the
// extra copy.
//
// witness for Phoûx.foo uses the Swift vtable
// CHECK-LABEL: _TFC14objc_witnessesX8Phox_xra3foo
// CHECK:      bb0([[IN_ADDR:%.*]] : 
// CHECK:         [[STACK_SLOT:%.*]] = alloc_stack $Phoûx
// CHECK:         copy_addr [[IN_ADDR]] to [initialization] [[STACK_SLOT]]
// CHECK:         [[VALUE:%.*]] = load [take] [[STACK_SLOT]]
// CHECK:         class_method [[VALUE]] : $Phoûx, #Phoûx.foo!1

protocol Bells {
  init(bellsOn: Int)
}

extension Gizmo : Bells {
}

// CHECK: sil hidden [transparent] [thunk] @_TTWCSo5Gizmo14objc_witnesses5BellsS0_FS1_C
// CHECK: bb0([[SELF:%[0-9]+]] : $*Gizmo, [[I:%[0-9]+]] : $Int, [[META:%[0-9]+]] : $@thick Gizmo.Type):

// CHECK:   [[INIT:%[0-9]+]] = function_ref @_TFCSo5GizmoC{{.*}} : $@convention(method) (Int, @thick Gizmo.Type) -> @owned Optional<Gizmo>
// CHECK:   [[IUO_RESULT:%[0-9]+]] = apply [[INIT]]([[I]], [[META]]) : $@convention(method) (Int, @thick Gizmo.Type) -> @owned Optional<Gizmo>
// CHECK:   switch_enum [[IUO_RESULT]]
// CHECK:   [[UNWRAPPED_RESULT:%[0-9]+]] = unchecked_enum_data [[IUO_RESULT]]
// CHECK:   store [[UNWRAPPED_RESULT]] to [init] [[SELF]] : $*Gizmo

// Test extension of a native @objc class to conform to a protocol with a
// subscript requirement. rdar://problem/20371661

protocol Subscriptable {
  subscript(x: Int) -> Any { get }
}

// CHECK-LABEL: sil hidden [transparent] [thunk] @_TTWCSo7NSArray14objc_witnesses13SubscriptableS0_FS1_g9subscriptFSiP_ : $@convention(witness_method) (Int, @in_guaranteed NSArray) -> @out Any {
// CHECK:         function_ref @_TTOFCSo7NSArrayg9subscriptFSiP_ : $@convention(method) (Int, @guaranteed NSArray) -> @out Any
// CHECK-LABEL: sil shared [thunk] @_TTOFCSo7NSArrayg9subscriptFSiP_ : $@convention(method) (Int, @guaranteed NSArray) -> @out Any {
// CHECK:         class_method [volatile] {{%.*}} : $NSArray, #NSArray.subscript!getter.1.foreign
extension NSArray: Subscriptable {}

// witness is a dynamic thunk:

protocol Orbital {
  var quantumNumber: Int { get set }
}

class Electron : Orbital {
  dynamic var quantumNumber: Int = 0
}

// CHECK-LABEL: sil hidden [transparent] [thunk] @_TTWC14objc_witnesses8ElectronS_7OrbitalS_FS1_g13quantumNumberSi
// CHECK-LABEL: sil shared [transparent] [thunk] @_TTDFC14objc_witnesses8Electrong13quantumNumberSi

// CHECK-LABEL: sil hidden [transparent] [thunk] @_TTWC14objc_witnesses8ElectronS_7OrbitalS_FS1_s13quantumNumberSi
// CHECK-LABEL: sil shared [transparent] [thunk] @_TTDFC14objc_witnesses8Electrons13quantumNumberSi

// witness is a dynamic thunk and is public:

public protocol Lepton {
  var spin: Float { get }
}

public class Positron : Lepton {
  public dynamic var spin: Float = 0.5
}

// CHECK-LABEL: sil [transparent] [fragile] [thunk] @_TToFC14objc_witnesses8Positrong4spinSf
// CHECK-LABEL: sil [transparent] [fragile] [thunk] @_TToFC14objc_witnesses8Positrons4spinSf

// Override of property defined in @objc extension

class Derived : NSObject {
  override var valence: Int {
    get { return 2 } set { }
  }
}

extension NSObject : Atom {
  var valence: Int { get { return 1 } set { } }
}

// CHECK-LABEL: sil hidden @_TFE14objc_witnessesCSo8NSObjectm7valenceSi : $@convention(method) (Builtin.RawPointer, @inout Builtin.UnsafeValueBuffer, @guaranteed NSObject) -> (Builtin.RawPointer, Optional<Builtin.RawPointer>) {
// CHECK: class_method [volatile] %2 : $NSObject, #NSObject.valence!getter.1.foreign
// CHECK: }

// CHECK-LABEL: sil hidden @_TFFE14objc_witnessesCSo8NSObjectm7valenceSiU_T_ : $@convention(thin) (Builtin.RawPointer, @inout Builtin.UnsafeValueBuffer, @inout NSObject, @thick NSObject.Type) -> () {
// CHECK: class_method [volatile] %4 : $NSObject, #NSObject.valence!setter.1.foreign
// CHECK: }

protocol Atom : class {
  var valence: Int { get set }
}
