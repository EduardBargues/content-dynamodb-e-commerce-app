set -e
WORKING_FOLDER=$(pwd)

FEATURES=('CreateCustomer' 'UpdateCustomerAddresses' 'CreateOrder' 'GetCustomerWithRecentOrders' 'GetOrder')
for feature in "${FEATURES[@]}"
do
    echo ""
    echo "====> PACKAGING LAMBDA $feature"
    echo ""
    cd "$WORKING_FOLDER/src/Features/$feature"
    package="$WORKING_FOLDER/terraform/$feature.zip"
    dotnet lambda package \
        -c release \
        --output-package $package
    cd $WORKING_FOLDER
done

cd $WORKING_FOLDER/terraform
    echo ""
    echo "====> TERRAFORM"
    echo ""
    terraform init
    terraform validate
    planFile="terraform.plan"
    terraform plan -out=$planFile
    terraform apply $planFile
    outputsFile="$WORKING_FOLDER/tests/api.json"
    rm -f $outputsFile
    terraform output -json >> $outputsFile
cd $WORKING_FOLDER

cd $WORKING_FOLDER/tests
    echo ""
    echo "====> E2E TESTS"
    echo ""
    npm i
    npm run e2e
cd $WORKING_FOLDER

cd $WORKING_FOLDER/terraform
    echo ""
    echo "====> TERRAFORM DESTROY"
    echo ""
    terraform destroy --auto-approve
cd $WORKING_FOLDER
