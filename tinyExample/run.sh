#!/bin/bash

mkdir -p compiled images

rm -f ./compiled/*.fst ./images/*.pdf

# ############ Compile source transducers ############
for i in sources/*.txt; do
	echo "Compiling: $i"
    fstcompile --isymbols=syms.txt --osymbols=syms.txt $i | fstarcsort > compiled/$(basename $i ".txt").fst
done

# ############ CORE OF THE PROJECT  ############
# a) 2
fstconcat compiled/mmm2mm.fst compiled/dumbparser.fst > compiled/mix2numerical.fst

# b) 3
fstconcat compiled/tradpt2en.fst compiled/dumbparser.fst > compiled/pt2en.fst

# b) 4
fstconcat compiled/traden2pt.fst compiled/dumbparser.fst > compiled/en2pt.fst

# c) 8
fstconcat compiled/month.fst compiled/slashparser.fst > compiled/monthslash.fst
fstconcat compiled/monthslash.fst compiled/day.fst > compiled/monthday.fst
fstconcat compiled/monthday.fst compiled/slash2coma.fst > compiled/monthdayslash.fst
fstconcat compiled/monthdayslash.fst compiled/year.fst > compiled/datenum2text.fst

# d) 9
fstcompose compiled/mmm2mm.fst compiled/month.fst > compiled/mmm2text.fst
fstconcat compiled/mmm2text.fst compiled/slashparser.fst > compiled/monthslash.fst
fstconcat compiled/monthslash.fst compiled/day.fst > compiled/monthday.fst
fstconcat compiled/monthday.fst compiled/slash2coma.fst > compiled/monthdayslash.fst
fstconcat compiled/monthdayslash.fst compiled/year.fst > compiled/mix2text.fst

# d) 10
fstunion compiled/pt2en.fst compiled/mmm2mm.fst > compiled/translated.fst
fstcompose compiled/translated.fst compiled/month.fst > compiled/mmm2text.fst
fstconcat compiled/mmm2text.fst compiled/slashparser.fst > compiled/monthslash.fst
fstconcat compiled/monthslash.fst compiled/day.fst > compiled/monthday.fst
fstconcat compiled/monthday.fst compiled/slash2coma.fst > compiled/monthdayslash.fst
fstconcat compiled/monthdayslash.fst compiled/year.fst > compiled/date2text.fst


# ############ generate PDFs  ############
echo "Starting to generate PDFs"
for i in compiled/*.fst; do
	echo "Creating image: images/$(basename $i '.fst').pdf"
   fstdraw --portrait --isymbols=syms.txt --osymbols=syms.txt $i | dot -Tpdf > images/$(basename $i '.fst').pdf
done



# ############      TESTS     ############

#3 - presents the output with the tokens concatenated (uses a different syms on the output)
fst2word() {
	awk '{if(NF>=3){printf("%s",$3)}}END{printf("\n")}'
}

trans=mix2numerical.fst
echo "\n***********************************************************"
echo "Testing mix2numerical.fst"
echo "*************************************************************"
for w in "SEP/20/2018"; do
    res=$(python3 ./scripts/word2fst.py $w | fstcompile --isymbols=syms.txt --osymbols=syms.txt | fstarcsort |
                       fstcompose - compiled/$trans | fstshortestpath | fstproject --project_type=output |
                       fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt | fst2word)
    echo "$w = $res"
done

trans=en2pt.fst
echo "\n***********************************************************"
echo "Testing EN2PT"
echo "*************************************************************"
for w in "MAY/01/2023"; do
    res=$(python3 ./scripts/word2fst.py $w | fstcompile --isymbols=syms.txt --osymbols=syms.txt | fstarcsort |
                       fstcompose - compiled/$trans | fstshortestpath | fstproject --project_type=output |
                       fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt | fst2word)
    echo "$w = $res"
done


trans=day.fst
echo "\n***********************************************************"
echo "Testing day.fst"
echo "*************************************************************"
for w in "02" "21" "3" "8" "31" "30" "17"; do
    res=$(python3 ./scripts/word2fst.py $w | fstcompile --isymbols=syms.txt --osymbols=syms.txt | fstarcsort |
                       fstcompose - compiled/$trans | fstshortestpath | fstproject --project_type=output |
                       fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./scripts/syms-out.txt | fst2word)
    echo "$w = $res"
done


trans=month.fst
echo "\n***********************************************************"
echo "Testing month.fst"
echo "*************************************************************"
for w in "02" "3" "8" "12" "1"; do
    res=$(python3 ./scripts/word2fst.py $w | fstcompile --isymbols=syms.txt --osymbols=syms.txt | fstarcsort |
                       fstcompose - compiled/$trans | fstshortestpath | fstproject --project_type=output |
                       fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./scripts/syms-out.txt | fst2word)
    echo "$w = $res"
done
echo "\nThe end"

trans=year.fst
echo "\n***********************************************************"
echo "Testing year.fst"
echo "*************************************************************"
for w in "2001" "2020" "2039" "2045" "2050" "2067" "2079" "2083" "2099"; do
    res=$(python3 ./scripts/word2fst.py $w | fstcompile --isymbols=syms.txt --osymbols=syms.txt | fstarcsort |
                       fstcompose - compiled/$trans | fstshortestpath | fstproject --project_type=output |
                       fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./scripts/syms-out.txt | fst2word)
    echo "$w = $res"
done
echo "\nThe end"

trans=datenum2text.fst
echo "\n***********************************************************"
echo "Testing datenum2text.fst"
echo "*************************************************************"
for w in "09/15/2075"; do
    res=$(python3 ./scripts/word2fst.py $w | fstcompile --isymbols=syms.txt --osymbols=syms.txt | fstarcsort |
                       fstcompose - compiled/$trans | fstshortestpath | fstproject --project_type=output |
                       fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./scripts/syms-out.txt | fst2word)
    echo "$w = $res"
done
echo "\nThe end"

trans=mix2text.fst
echo "\n***********************************************************"
echo "Testing mix2text.fst"
echo "*************************************************************"
for w in "MAY/15/2075"; do
    res=$(python3 ./scripts/word2fst.py $w | fstcompile --isymbols=syms.txt --osymbols=syms.txt | fstarcsort |
                       fstcompose - compiled/$trans | fstshortestpath | fstproject --project_type=output |
                       fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./scripts/syms-out.txt | fst2word)
    echo "$w = $res"
done
echo "\nThe end"

trans=date2text.fst
echo "\n***********************************************************"
echo "Testing date2text.fst EN"
echo "*************************************************************"
for w in "MAY/15/2075"; do
    res=$(python3 ./scripts/word2fst.py $w | fstcompile --isymbols=syms.txt --osymbols=syms.txt | fstarcsort |
                       fstcompose - compiled/$trans | fstshortestpath | fstproject --project_type=output |
                       fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./scripts/syms-out.txt | fst2word)
    echo "$w = $res"
done
echo "\nThe end"

trans=date2text.fst
echo "\n***********************************************************"
echo "Testing date2text.fst PT"
echo "*************************************************************"
for w in "MAI/15/2075"; do
    res=$(python3 ./scripts/word2fst.py $w | fstcompile --isymbols=syms.txt --osymbols=syms.txt | fstarcsort |
                       fstcompose - compiled/$trans | fstshortestpath | fstproject --project_type=output |
                       fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./scripts/syms-out.txt | fst2word)
    echo "$w = $res"
done
echo "\nThe end"