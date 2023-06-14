ejecutar qemu sin programa
    qemu-system-x86_64 -s

ejecutar qemu:
    qemu-x86_64 -g 1234 benchmark.elf "te amo soto"

r16 es el instruction pointer
r17 son las flags 

Potencia: 
    Core:     Xeon W-3323
    Freq:     3.5 GHz                 (según wiki)
    TDP:      220 W => 62858 pJ       (según wiki)
    baseline: 12  W => 3429  pJ/cycle (según hacker news) 
    
    MUL:        10  * ALU   => 8220 pJ/cycle/unit 
    LOAD/STORE: 5   * ALU   => 4110 pJ/cycle/unit
    BRANCH:     2.5 * ALU   => 2055 pJ/cycle/unit
    DE:         2   * ALU   => 1644 pJ/cycle/unit
    ALU:        1.5 * IS    => 822  pJ/cycle/unit
    IS:         2   * WB    => 548  pJ/cycle/unit
    WB:         1.1 * FE    => 274  pJ/cycle/unit
    FE:         1           => 249  pJ/cycle/unit   

    ALU*4 + Branch*2 + Load*2 + Store*4 + Mul*3 + DE + IS + WB + FE = TDP - baseline

    (tdp - baseline) / (1.5*2*1.1*4 + 2.5*1.5*2*1.1*2 + 5*1.5*2*1.1*6 + 10*1.5*2*1.1*3 + 2*1.5*2*1.1 + 2*1.1 + 1.1 + 1)

    