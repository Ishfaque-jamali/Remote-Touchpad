import 'dart:ffi';
import 'package:ffi/ffi.dart';

void moveMouseBy(int dx, int dy) {
  try {
    final user32 = DynamicLibrary.open('user32.dll');

    final getCursorPos = user32.lookupFunction<
        Int32 Function(Pointer<POINT>),
        int Function(Pointer<POINT>)>('GetCursorPos');

    final setCursorPos = user32.lookupFunction<
        Int32 Function(Int32, Int32),
        int Function(int, int)>('SetCursorPos');

    final pointPtr = calloc<POINT>();
    getCursorPos(pointPtr);

    final newX = pointPtr.ref.x + dx;
    final newY = pointPtr.ref.y + dy;
    setCursorPos(newX, newY);

    calloc.free(pointPtr);
  } catch (e) {
    print("🧨 moveMouseBy failed: $e");
  }
}

void simulateClick({required bool left}) {
  final user32 = DynamicLibrary.open("user32.dll");
  final mouse_event = user32.lookupFunction<
      Void Function(Uint32, Uint32, Uint32, Uint32, IntPtr),
      void Function(int, int, int, int, int)>('mouse_event');

  const LEFTDOWN = 0x0002, LEFTUP = 0x0004;
  const RIGHTDOWN = 0x0008, RIGHTUP = 0x0010;

  if (left) {
    mouse_event(LEFTDOWN, 0, 0, 0, 0);
    mouse_event(LEFTUP, 0, 0, 0, 0);
  } else {
    mouse_event(RIGHTDOWN, 0, 0, 0, 0);
    mouse_event(RIGHTUP, 0, 0, 0, 0);
  }
}

void simulateScroll(int amount) {
  final user32 = DynamicLibrary.open("user32.dll");
  final mouse_event = user32.lookupFunction<
      Void Function(Uint32, Uint32, Uint32, Uint32, IntPtr),
      void Function(int, int, int, int, int)>('mouse_event');

  const MOUSEEVENTF_WHEEL = 0x0800;
  mouse_event(MOUSEEVENTF_WHEEL, 0, 0, amount, 0);
}

void simulateDrag({required bool start}) {
  final user32 = DynamicLibrary.open("user32.dll");
  final mouse_event = user32.lookupFunction<
      Void Function(Uint32, Uint32, Uint32, Uint32, IntPtr),
      void Function(int, int, int, int, int)>('mouse_event');

  const LEFTDOWN = 0x0002, LEFTUP = 0x0004;
  mouse_event(start ? LEFTDOWN : LEFTUP, 0, 0, 0, 0);
}

base class POINT extends Struct {
  @Int32()
  external int x;

  @Int32()
  external int y;
}