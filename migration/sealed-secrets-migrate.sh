#!/usr/bin/env bash
set -ex

# Example of script ./migration/sealed-secrets-migrate.sh perftest camunda
git clean -f apps/ clusters/ k8s/
git checkout apps/ clusters/ k8s/

for file in $(grep -lr "kind: SealedSecret" k8s ); do
  FILE_NAME=$(echo ${file//*\/})
  ENV=$(echo $file | cut -d '/' -f2)

  NAMESPACE=$(yq eval '.metadata.namespace' $file)

   if [[ $NAMESPACE == "default" ]]
      then
        NAMESPACE="neuvector"
    fi

  mv $file apps/$NAMESPACE/$ENV/base/
  FILE_PATH="$FILE_NAME" yq eval -i '.resources += [env(FILE_PATH)]' apps/$NAMESPACE/$ENV/base/kustomization.yaml

done

