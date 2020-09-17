#/usr/bin/env bash

# this script evals the following fsmt models
# it covers:
# - allenai/wmt19-de-en-6-6-base
# - allenai/wmt19-de-en-6-6-big

# this script needs to be run from the top level of the transformers repo
if [ ! -d "src/transformers" ]; then
    echo "Error: This script needs to be run from the top of the transformers repo"
    exit 1
fi

# In these scripts you may have to lower BS if you get CUDA OOM (or increase it if you have a large GPU)

### Normal eval ###

export PAIR=de-en
export DATA_DIR=data/$PAIR
export SAVE_DIR=data/$PAIR
export BS=64
export NUM_BEAMS=5
mkdir -p $DATA_DIR
sacrebleu -t wmt19 -l $PAIR --echo src > $DATA_DIR/val.source
sacrebleu -t wmt19 -l $PAIR --echo ref > $DATA_DIR/val.target

MODEL_PATH=allenai/wmt19-de-en-6-6-base
echo $PAIR $MODEL_PATH
PYTHONPATH="src:examples/seq2seq" python examples/seq2seq/run_eval.py $MODEL_PATH $DATA_DIR/val.source $SAVE_DIR/test_translations.txt --reference_path $DATA_DIR/val.target --score_path $SAVE_DIR/test_bleu.json --bs $BS --task translation --num_beams $NUM_BEAMS

MODEL_PATH=allenai/wmt19-de-en-6-6-big
echo $PAIR $MODEL_PATH
PYTHONPATH="src:examples/seq2seq" python examples/seq2seq/run_eval.py $MODEL_PATH $DATA_DIR/val.source $SAVE_DIR/test_translations.txt --reference_path $DATA_DIR/val.target --score_path $SAVE_DIR/test_bleu.json --bs $BS --task translation --num_beams $NUM_BEAMS



### Searching hparams eval ###

export PAIR=de-en
export DATA_DIR=data/$PAIR
export SAVE_DIR=data/$PAIR
export BS=16
export NUM_BEAMS=5
mkdir -p $DATA_DIR
sacrebleu -t wmt19 -l $PAIR --echo src > $DATA_DIR/val.source
sacrebleu -t wmt19 -l $PAIR --echo ref > $DATA_DIR/val.target

MODEL_PATH=allenai/wmt19-de-en-6-6-base
echo $PAIR $MODEL_PATH
PYTHONPATH="src:examples/seq2seq" python examples/seq2seq/run_eval_search.py $MODEL_PATH $DATA_DIR/val.source $SAVE_DIR/test_translations.txt --reference_path $DATA_DIR/val.target --score_path $SAVE_DIR/test_bleu.json --bs $BS --task translation --search="num_beams=5:10:15 length_penalty=0.6:0.7:0.8:0.9:1.0:1.1"

MODEL_PATH=allenai/wmt19-de-en-6-6-big
echo $PAIR $MODEL_PATH
PYTHONPATH="src:examples/seq2seq" python examples/seq2seq/run_eval_search.py $MODEL_PATH $DATA_DIR/val.source $SAVE_DIR/test_translations.txt --reference_path $DATA_DIR/val.target --score_path $SAVE_DIR/test_bleu.json --bs $BS --task translation --search="num_beams=5:10:15 length_penalty=0.6:0.7:0.8:0.9:1.0:1.1"
