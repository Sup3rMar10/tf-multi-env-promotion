# tf-multi-env-promotion

A Terraform pipeline that promotes the same change through **dev, then stage, then prod**, with one shared module and one small root per environment.

A local file stands in for a real service (`hashicorp/local`), so it runs with no cloud account.

## Layout

```
modules/service/     the shared definition, with validation rules that live with the module
envs/dev|stage|prod/ one root each: same module, different values, its own state
```

The module refuses `replicas < 1`, and refuses **`prod` with fewer than 2 replicas**, so no environment file can bypass the rule.

## Flow

```
pull request --> plan all three environments in parallel (matrix)
merge to main --> apply dev --> apply stage --> apply prod   (one at a time, stops on failure)
```

## What was checked (2026-10-16)

- **Locally:** init, validate and plan for all three environments; setting prod to 1 replica fails with `Invalid value for variable` and the module's message.
- **On GitHub Actions:** the `main` run succeeded: three plans, then three applies in order.
- **Not tested:** required reviewers on the `stage` and `prod` GitHub environments (not configured, so nothing actually paused for approval), and anything against a real cloud.

## Decisions

- **Directory per environment, not workspaces.** Each environment has its own state and can differ in shape or provider settings; the cost is some repeated boilerplate. Workspaces share one config and are easy to apply to the wrong environment.
- **`max-parallel: 1` with `fail-fast: true`** gives an ordered promotion that stops when an earlier environment fails.
- **`environment: ${{ matrix.env }}`** is the approval hook: add required reviewers to `stage` and `prod` and the pipeline pauses before them.
- **Committed lock files** per environment, hashes for five platforms.

## Honest limits

- **State is not persisted** between runs (local state on a fresh runner). Real use needs a separate remote backend key per environment (see `tf-state-bootstrap`).
- This promotes *the same commit* through environments; it does not promote a built artifact (see `k8s-cicd-gitops` for image promotion).
- No drift detection (see `tf-drift-detection`), no per-environment credentials.

MIT licensed.
