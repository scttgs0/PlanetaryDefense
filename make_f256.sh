
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
