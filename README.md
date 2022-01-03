# Renovate minimal reproduction for flapping upgrade when combining Terraform artifacts upgrades

This repository contains a minimal RenovateBot configuration with a few code references to demonstrate a bug in renovate.

## Scenario

Terraform provider upgrades should be grouped together. Furthermore, the Terraform version should also be bumped (via a regex manager here). To keep the terraform files free of noisy changes, `"rangeStrategy": "update-lockfile"` is set: renovate should only update the lockfile.

## The issue

One each run, Renovate flags the branch state from the correct upgrades to only the terraform lockfile upgrades (forgetting the regex file changes) and back. It is noisy and requires care to merge this upgrade at the right state.

Furthermore, it makes it impossible to request the upgrade out-of-schedule if `prCreation` is set to `not-pending`: it would require two runs with the same outcome.

## Renovate Log

```
DEBUG: isLockFileUpdate without updateLockedDependency (repository=msw-kialo/renovate-flapping-grouped-terraform-updates, branch=renovate/terraform)
       "manager": "terraform"
DEBUG: Branch dep is already updated (repository=msw-kialo/renovate-flapping-grouped-terraform-updates, packageFile=versions.sh, branch=renovate/terraform)
       "depName": "hashicorp/terraform"
DEBUG: No content changed (repository=msw-kialo/renovate-flapping-grouped-terraform-updates, packageFile=versions.sh, branch=renovate/terraform)
       "depName": "hashicorp/terraform"
DEBUG: terraform.updateArtifacts(terraform/main.tf) (repository=msw-kialo/renovate-flapping-grouped-terraform-updates, branch=renovate/terraform)
DEBUG: Updated 1 package files (repository=msw-kialo/renovate-flapping-grouped-terraform-updates, branch=renovate/terraform)
DEBUG: Updated 1 lock files (repository=msw-kialo/renovate-flapping-grouped-terraform-updates, branch=renovate/terraform)
       "updatedArtifacts": ["terraform/.terraform.lock.hcl"]
DEBUG: Retrieved closed PR list with graphql (repository=msw-kialo/renovate-flapping-grouped-terraform-updates, branch=renovate/terraform)
       "prNumbers": [...]
DEBUG: Getting comments for #87 (repository=msw-kialo/renovate-flapping-grouped-terraform-updates, branch=renovate/terraform)
DEBUG: Found 0 comments (repository=msw-kialo/renovate-flapping-grouped-terraform-updates, branch=renovate/terraform)
DEBUG: 2 file(s) to commit (repository=msw-kialo/renovate-flapping-grouped-terraform-updates, branch=renovate/terraform)
DEBUG: Committing files to branch renovate/terraform (repository=msw-kialo/renovate-flapping-grouped-terraform-updates, branch=renovate/terraform)
DEBUG: git commit (repository=msw-kialo/renovate-flapping-grouped-terraform-updates, branch=renovate/terraform)
       "deletedFiles": [],
       "ignoredFiles": [],
       "result": {
         "author": null,
         "branch": "renovate/terraform",
         "commit": "cf6be26768b",
         "root": false,
         "summary": {"changes": 1, "insertions": 12, "deletions": 2}
       }
DEBUG: git push (repository=msw-kialo/renovate-flapping-grouped-terraform-updates, branch=renovate/terraform)
       "result": {
         "pushed": [],
         "branch": {
           "local": "renovate/terraform",
           "remote": "renovate/terraform",
           "remoteName": "origin"
         },
         "ref": {"local": "refs/remotes/origin/renovate/terraform"},
         "remoteMessages": {"all": []}
       }
 INFO: Branch updated (repository=msw-kialo/renovate-flapping-grouped-terraform-updates, branch=renovate/terraform)
       "commitSha": "cf6be26768b"

```

As seen in the log, the regex manager correctly determines the branch is out-to-date, but the Terraform artifacts are updated and only these change are committed and pushed afterwards.

Note the difference between `2 file(s) to commit` and the wrong commit that only includes the one artifact file.
