package ru.lab.asmserver;

public class RunAsmResponse {
    private String stdout;
    private int exitCode;

    public RunAsmResponse(String stdout, int exitCode) {
        this.stdout = stdout;
        this.exitCode = exitCode;
    }

    public String getStdout() {
        return stdout;
    }

    public int getExitCode() {
        return exitCode;
    }
}
