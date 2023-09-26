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
echo "Testing DAY"
echo "*************************************************************"
for w in "02" "21" "3" "8" "31" "30" "17"; do
    res=$(python3 ./scripts/word2fst.py $w | fstcompile --isymbols=syms.txt --osymbols=syms.txt | fstarcsort |
                       fstcompose - compiled/$trans | fstshortestpath | fstproject --project_type=output |
                       fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt | fst2word)
    echo "$w = $res"
done


trans=month.fst
echo "\n***********************************************************"
echo "Testing MONTH"
echo "*************************************************************"
for w in "02" "3" "8" "12" "1"; do
    res=$(python3 ./scripts/word2fst.py $w | fstcompile --isymbols=syms.txt --osymbols=syms.txt | fstarcsort |
                       fstcompose - compiled/$trans | fstshortestpath | fstproject --project_type=output |
                       fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt | fst2word)
    echo "$w = $res"
done
echo "\nThe end"

trans=year.fst
echo "\n***********************************************************"
echo "Testing YEAR"
echo "*************************************************************"
for w in "2001" "2020" "2039" "2045" "2050" "2067" "2079" "2083" "2099"; do
    res=$(python3 ./scripts/word2fst.py $w | fstcompile --isymbols=syms.txt --osymbols=syms.txt | fstarcsort |
                       fstcompose - compiled/$trans | fstshortestpath | fstproject --project_type=output |
                       fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./scripts/syms-out.txt | fst2word)
    echo "$w = $res"
done
echo "\nThe end"

