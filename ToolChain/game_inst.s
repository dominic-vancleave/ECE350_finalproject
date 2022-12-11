.text

nop
nop
nop
addi $r1, $r0, 300
addi $r2, $r0, 420 
addi $r5, $r0, 9

io_loop_level1:
  blt $r5, $r3, buttonPress_level2
  bio     buttonPress_level1
  j       io_loop_level1

buttonPress_level1:
  wait (x4)
  addi $r2, $r2, -60 
  wait (x4)
  addi $r2, $r2, -40
  wait (x4)
  addi $r2, $r2, -30
  wait (x4)
  addi $r2, $r2, -20
  wait (x4)
  addi $r2, $r2, -10
  wait (x4)
  addi $r2, $r2, -5
  wait (x4)
  addi $r2, $r2, 5
  wait (x4)
  addi $r2, $r2, 10
  wait (x4)
  addi $r2, $r2, 20
  wait (x4)
  addi $r2, $r2, 30
  wait (x4)
  addi $r2, $r2, 40
  wait (x4)
  addi $r2, $r2, 60
  wait (x2)
  addi $r3, $r3, 1
  j io_loop_level1
io_loop_level2:
  bio     buttonPress_level2
  j       io_loop_level2

buttonPress_level2:
  wait (x4)
  addi $r2, $r2, -40 
  wait (x4)
  addi $r2, $r2, -20
  wait (x4)
  addi $r2, $r2, -10
  wait (x4)
  addi $r2, $r2, -5
  wait (x4)
  addi $r2, $r2, -2
  wait (x4)
  addi $r2, $r2, 2
  wait (x4)
  addi $r2, $r2, 5
  wait (x4)
  addi $r2, $r2, 10
  wait (x4)
  addi $r2, $r2, 20
  wait (x4)
  addi $r2, $r2, 40
  wait (x2)
  addi $r3, $r3, 2
  j io_loop_level2