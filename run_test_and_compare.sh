if [ "$1" = "all" ]
then
    echo "all"
    for source_file in programs/*.s programs/*c; do
        program=$(echo "$source_file" | cut -d '.' -f1 | cut -d '/' -f 2)
        echo "Running $program with current processor"
        make $program.out

        cp "$source_file" "original_processor/programs"
    done 

    cd original_processor

    for source_file in programs/*.s programs/*c; do
        program=$(echo "$source_file" | cut -d '.' -f1 | cut -d '/' -f 2)
        echo "Running $program with original processor"
        make $program.out
        
    done

    cd ..

    echo "Comparing all writeback and memory output files"
    
    for output_file in output/*.wb; do
        test=$(echo "$output_file" | cut -d '.' -f1 | cut -d '/' -f 2)

        echo "Comparing $test"

        diff "output/$test.wb" "original_processor/output/$test.wb"
        if [ $? -eq 1 ]; then
            echo "$test.wb is different."
            echo "Failed"
            exit 1
        fi

        diff <(grep "@@@" "output/$test.out") <(grep "@@@" "original_processor/output/$test.out")
        if [ $? -eq 1 ]; then
            echo "$test.out is different."
            echo "Failed"
            exit 1
        fi
    done

    echo "Writeback and Memory output matched. Passed."
    
    exit
fi


for source_file in programs/*.s programs/*c; do
    program=$(echo "$source_file" | cut -d '.' -f1 | cut -d '/' -f 2)
    if [ "$program" = "$1" ]
    then
        echo "Running $program with current processor"
        make $program.out

        cp "$source_file" "original_processor/programs"
        break
    fi
done 

cd original_processor

for source_file in programs/*.s programs/*c; do
    program=$(echo "$source_file" | cut -d '.' -f1 | cut -d '/' -f 2)
    if [ "$program" = "$1" ]
    then
        echo "Running $program with original processor"
        make $program.out
        break
    fi
done 

cd ..

echo "Comparing writeback output file"

diff "output/$1.wb" "original_processor/output/$1.wb"

if [ $? -eq 1 ]; then
    echo "$1.wb is different."
    echo "Failed"
    exit 1
fi

echo "Writeback output matched. Passed."

echo "Comparing memory output file"

diff <(grep "@@@" "output/$1.out") <(grep "@@@" "original_processor/output/$1.out")

if [ $? -eq 1 ]; then
    echo "$1.out is different."
    echo "Failed"
    exit 1
fi

echo "Memory output matched. Passed."

