
mkdir -p obj/

# -------------------------------------

64tass  --m65c02 \
        --flat \
        --nostart \
        -D PGX=1 \
        -o obj/pdefense.pgx \
        --list=obj/pdefense.lst \
        --labels=obj/pdefense.lbl \
        planetarydefense.asm


64tass  --m65c02 \
        --flat \
        --nostart \
        -D PGX=0 \
        -o obj/pdefense.bin \
        --list=obj/pdefenseB.lst \
        --labels=obj/pdefenseB.lbl \
        planetarydefense.asm
