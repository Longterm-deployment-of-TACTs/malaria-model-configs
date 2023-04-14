#!/bin/bash

function ProgressBar {
# Process data
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done
# Build progressbar string lengths
    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")

# 1.2 Build progressbar strings and print the ProgressBar line
# 1.2.1 Output example:                           
# 1.2.1.1 Progress : [########################################] 100%
printf "\rProgress : [${_fill// /\#}${_empty// /-}] ${_progress}%%"

}

shout() { echo "$0: $*" >&2; }
die() { shout "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }

function pause(){
   read -p "$*"
}

# declare -a parameter_list=("mda.num_teams")


# Exx='E01'
# num_runs_per_config=100

base_config='./config.19.tact.json'

DIR="${BASH_SOURCE%/*}"

if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

source "$DIR/run_shared.sh"


ii=0

ii_new=0

if [ ! -d $Sxx ]; then
    mkdir -p $Sxx
else
    pause "\nSpecified directory [$Sxx] already exists, Ctrl+C now to avoid unintended overwrites.\n"
fi

# for (( uu = 0; uu < ${#mutation_prob_single_list_verbal[@]}; uu++ )); do
# for (( aa = 0; aa < ${#mutation_prob_a2b_ratio_list[@]}; aa++ )); do
        
for (( ff = 0; ff < ${#first_line_list[@]}; ff++ )); do
for (( cc = 0; cc < ${#coverage_list[@]}; cc++ )); do
for (( pp = 0; pp < ${#prev_list[@]}; pp++ )); do
for (( tt = 0; tt < ${#tact_list[@]}; tt++ )); do

        first_line="${first_line_list[$ff]}"
        coverage="${coverage_list[$cc]}"
        prevalence="${prev_list[$pp]}"
        init_prev="${init_prev_list[$pp]}"
        tact="${tact_list[$tt]}"

        if [ "${tact}" = "base" ]; then
            tact="${first_line}"
        fi

        outside_combi_str="A123_${first_line}_${coverage}_${prevalence}_${tact}"

        Exx=E_${outside_combi_str}

        if [ ! -d $Sxx/$Exx ]; then
            mkdir -p $Sxx/$Exx
        fi


        # for (( bb = 0; bb < ${#init_rb_list[@]}; bb++ )); do
        
            # inside_combi_str="${init_rb_list[$bb]}"
            # combi="${outside_combi_str}_${inside_combi_str}"
            
            combi="${outside_combi_str}"

            dir_combi="${Sxx}/${Exx}/${combi}"

            if [ ! -d $dir_combi ]; then

                mkdir -p ${dir_combi}/outputs

                betaf=""

                if [ "${first_line}" = "12" ]; then
                    if [ "${prevalence}" = "0.001" ]; then
                        betaf="${betaf_list_a1_prev1[$cc]}"
                    fi
                    if [ "${prevalence}" = "0.01" ]; then
                        betaf="${betaf_list_a1_prev2[$cc]}"
                    fi
                    if [ "${prevalence}" = "0.1" ]; then
                        betaf="${betaf_list_a1_prev3[$cc]}"
                    fi
                fi

                if [ "${first_line}" = "10" ]; then
                    if [ "${prevalence}" = "0.001" ]; then
                        betaf="${betaf_list_a2_prev1[$cc]}"
                    fi
                    if [ "${prevalence}" = "0.01" ]; then
                        betaf="${betaf_list_a2_prev2[$cc]}"
                    fi
                    if [ "${prevalence}" = "0.1" ]; then
                        betaf="${betaf_list_a2_prev3[$cc]}"
                    fi
                fi

                if [ "${first_line}" = "8" ]; then
                    if [ "${prevalence}" = "0.001" ]; then
                        betaf="${betaf_list_a3_prev1[$cc]}"
                    fi
                    if [ "${prevalence}" = "0.01" ]; then
                        betaf="${betaf_list_a3_prev2[$cc]}"
                    fi
                    if [ "${prevalence}" = "0.1" ]; then
                        betaf="${betaf_list_a3_prev3[$cc]}"
                    fi
                fi

                try jq ".simulation.title=\"TACT, ${combi//[_]/-}\"" ${base_config} | \
                    jq ".infection.init_with_uniform_prevalence_with=${init_prev}" | \
                    jq ".infection.transmission_coefficient_to_beta_scaling_factor=${betaf}" | \
                    jq ".treatment.tact.coverage=${coverage}" | \
                    jq ".treatment.tact.first_line_drug_b=${tact}" | \
                    jq ".treatment.tact.first_line_drug_a=${first_line}" > \
                    ${dir_combi}/config.json

                ii_new=$[ $ii_new + 1 ]

            fi

            ii=$[ $ii + 1 ]
            
            echo "${ii}/${ii_new} : ${combi}"
            
        # done # bb init_b

done
done
done
done


echo "Total number of configs: ${ii}, newly created: ${ii_new}."


