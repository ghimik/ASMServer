package ru.lab.asmserver;

public class RunAsmRequest {
    private String asm;

    public RunAsmRequest(String asm) {
        this.asm = asm;
    }

    public String getAsm() {
        return asm;
    }
}
