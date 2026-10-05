
.data
    nSamples:	.word 4
    minValue:	.word 0
    maxValue:	.word 255
    const1:		.word 1
    const2:		.word 2
    const3:		.word 3
    sample0:	.word 15
    sample1:	.word -4
    sample2:	.word 221
    sample3:	.word 317

.text
.globl main
    main:
        jal init
        li  $k0, 1

    init:
        lw $t0, nSamples
        and $t1, $zero, $zero
        lw $t8, minValue
        lw $t9, maxValue
        lw $t5, const1
        lw $t6, const2
        lw $t7, const3

    loop:
        beq $t1, $t0, end

        beq $t1, $zero, loadFirst
        beq $t1, $t5, loadSecond
        beq $t1, $t6, loadThird
        beq $t1, $t7, loadFourth

        loadFirst:
            lw $t2, sample0
            j  clip

        loadSecond:
            lw $t2, sample1
            j  clip

        loadThird:
            lw $t2, sample2
            j  clip

        loadFourth:
            lw $t2, sample3
            j  clip

        clip:
            slt $t3, $t2, $t8
            beq $t3, $t5, clipMin
            slt $t3, $t9, $t2
            beq $t3, $t5, clipMax
            j   incLoopCounter

            clipMin:
                add $t2, $t8, $zero
                j   storeSample

            clipMax:
                add $t2, $t9, $zero

        storeSample:
            beq $t1, $zero, storeFirst
            beq $t1, $t5,   storeSecond
            beq $t1, $t6,   storeThird
            beq $t1, $t7,   storeFourth

            storeFirst:
                sw $t2, sample0
                j incLoopCounter

            storeSecond:
                sw $t2, sample1
                j incLoopCounter

            storeThird:
                sw $t2, sample2
                j incLoopCounter

            storeFourth:
                sw $t2, sample3

        incLoopCounter:
            add $t1, $t1, $t5
            j   loop

    end:
        jr $ra
