### Backend
By default this playbook stores the state in s3.
You can remove the backend block if you don't want to store the state in s3 and keep it in local.

### Init
```
terraform init
```

### Run Plan
```
terraform plan --out=./plan.output
```

### Apply
```
terraform apply ./plan.output
```

### Destroy
```
terraform plan --destroy --out=./plan.output
terraform apply ./plan.output
```




