#! /usr/bin/env bash

set -eo pipefail

dao=0x0f14341A7f464320319025540E8Fe48Ad0fe5aec
create2=0x914d7Fec6aaC8cd542e72Bca78B30650d45643d7

out_dir=$PWD/out
ormp_abi=$(jq -r '.bytecode.object' $out_dir/ORMP.sol/ORMP.json)
oracle_abi=$(jq -r '.bytecode.object' $out_dir/Oracle.sol/Oracle.json)
relayer_abi=$(jq -r '.bytecode.object' $out_dir/Relayer.sol/Relayer.json)

ormp_args=$(ethabi encode params -v address ${dao:2})
ormp_initcode=$ormp_abi$ormp_args

ormp_out=$(cast create2 -i $ormp_initcode -d $create2 --starts-with "0000000000" | grep -E '(Address:|Salt:)')
ormp_addr=$(echo $ormp_out | awk '{print $2}' )
ormp_salt=$(seth --to-uint256 $(echo $ormp_out | awk '{print $4}' ))
echo -e "ORMP: \n Address: $ormp_addr \n Salt:    $ormp_salt"

oracle_args=$(ethabi encode params -v address ${dao:2} -v address ${ormp_addr:2})
oracle_initcode=$oracle_abi$oracle_args
oracle_out=$(cast create2 -i $oracle_initcode -d $create2 --starts-with "00000000" | grep -E '(Address:|Salt:)')
oracle_addr=$(echo $oracle_out | awk '{print $2}' )
oracle_salt=$(seth --to-uint256 $(echo $oracle_out | awk '{print $4}' ))
echo -e "Oracle: \n Address: $oracle_addr \n Salt:    $oracle_salt"

relayer_args=$(ethabi encode params -v address ${dao:2} -v address ${ormp_addr:2})
relayer_initcode=$relayer_abi$relayer_args
relayer_out=$(cast create2 -i $relayer_initcode -d $create2 --starts-with "00000000" | grep -E '(Address:|Salt:)')
relayer_addr=$(echo $relayer_out | awk '{print $2}' )
relayer_salt=$(seth --to-uint256 $(echo $relayer_out | awk '{print $4}' ))
echo -e "Relayer: \n Address: $relayer_addr \n Salt:    $relayer_salt"
