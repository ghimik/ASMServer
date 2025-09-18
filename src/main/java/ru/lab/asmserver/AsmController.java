package ru.lab.asmserver;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

@RestController
public class AsmController {

    @PostMapping("/run_asm")
    public ResponseEntity<RunAsmResponse> runAsm(@RequestBody RunAsmRequest body) throws IOException, InterruptedException {
        String asmCode = body.getAsm();

        Path dir = Files.createTempDirectory("asm");
        Path asmFile = dir.resolve("prog.asm");
        Path objFile = dir.resolve("prog.o");
        Path binFile = dir.resolve("prog");

        Files.writeString(asmFile, asmCode);

        ProcessBuilder nasm = new ProcessBuilder("nasm", "-f", "elf64", asmFile.toString(), "-o", objFile.toString());
        nasm.directory(dir.toFile());
        Process p1 = nasm.start();
        int code1 = p1.waitFor();

        ProcessBuilder ld = new ProcessBuilder("ld", objFile.toString(), "-o", binFile.toString());
        ld.directory(dir.toFile());
        Process p2 = ld.start();
        int code2 = p2.waitFor();

        ProcessBuilder run = new ProcessBuilder(binFile.toString());
        run.directory(dir.toFile());
        run.redirectErrorStream(true);
        Process p3 = run.start();
        String output = new String(p3.getInputStream().readAllBytes());
        int code3 = p3.waitFor();

        return ResponseEntity.ok(new RunAsmResponse(output, code3));
    }
}
