echo "7번 tm이 중지된 상태일때"
echo "1 -> 7로 private contract 생성 될 경우"
echo " "

echo "istanbul_txmanager7_1 정지"
docker stop istanbul_txmanager7_1 > /dev/null

echo "private contract 생성"
result=`docker exec -it istanbul_node1_1 geth attach /qdata/dd/geth.ipc --exec "loadScript('/testScripts/tmTrouble/privateContractTo7.js')"`
transactionAddress=${result:0:66}

if [ ${transactionAddress:0:2} == "0x" ]; then
    echo "transactionAddress : $transactionAddress"
else
    echo "error ------------"
    echo $result
    echo " "
    echo "---------------------------------------------------------"
    echo "public contract 생성"
    result=`docker exec -it istanbul_node1_1 geth attach /qdata/dd/geth.ipc --exec "loadScript('/testScripts/tmTrouble/publicContract.js')"`
    transactionAddress=${result:0:66}
fi

getNodeData() {
    docker exec -it istanbul_node$1_1 geth attach /qdata/dd/geth.ipc \
        --exec "loadScript('/testScripts/tmTrouble/checkPrivate.js');
                var contract = new Contract('$2');
                contract.get();"
}

echo "sleep 5"
    sleep 5

echo "node1 data"
getNodeData 1 $transactionAddress
echo "node2 data"
getNodeData 2 $transactionAddress
echo "node7 data"
getNodeData 7 $transactionAddress

echo "tm이 중지됬을때 public을 조회하면 panic: MustNew:~~ 문제가 생기는데"
echo "docker-compose 파일의  environment: PRIVATE_CONFIG=/qdata/tm/tm.ipc 을 없애면"
echo "tm 없이 public은 사용 가능"