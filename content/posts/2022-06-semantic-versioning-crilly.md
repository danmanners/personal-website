+++ 
draft = false
date = 2022-06-25T13:24:17-04:00
title = "Semantic Versioning for IAC"
slug = "2022-06-semantic-versioning-michael-crilly" 
tags = ['semantic-versioning']
categories = ['git','versioning','iac','terraform','gitops']
+++

> This post was written by [Michael Crilly](https://www.youtube.com/c/MichaelCrilly), and this is simply a re-upload as the original source was taken down. All credit is his, and his alone!

# Semantic Versioning for IAC

When it comes to Infrastructure As Code, the software versioning system known as Semantic Versioning (semver.org) works from an API perspective but falls short elsewhere.

In short a semver is broken down into three "octets" and optional, additional information tagged to the end. Here are a few examples: `v1.0.1`, `v3.1.1`, `v1.15.0-4`. Each of these is a valid semver.

If we take the first example - `v1.0.1` - and change the first octet, `1`, to `2`, we're saying the following:

There has been a change to this code and that change is not compatible with how you're using `v1.0.1`. The change is a breaking change. You should take care to introduce version `v2.0.0` into your code or your environment.

This is perfectly fine for a RESTful API, a C library or a SaaS product, but it doesn't quite work for IAC.

With IAC (I use Terraform) you can change the API to a module with a breaking change - you can promote `v1.0.0` to `v2.0.0` - and people will know they're going to be dealing with something a bit more involved changing what version they're consuming. This is just like software when consuming a library - we sort of know what to expect.

But you can change the API to a Terraform module with a non-breaking change - you can promote `v1.0.0` to `v1.1.3` - producing a new version of a module that literally deletes EC2 Instances and recreates them, but the version did not reflect this directly.

So the question is do we take a promotion of the major version to mean the API has changed and there are changes that will delete resources? What about just rebuilding something?

Another question we can ask here is: do we use a change log, `README.md` update, email, etc. to notify people of the impact of upgrading? What if this gets overlooked or forgotten?

What happens when a major version change happens but it's just because of an API change not a change that rebuilds resources? That's a big change to the version number for introducing a new input.

## A Better Way

I propose that for IAC we create a Semantic Version that's more suitable to the declarative nature of IAC's function in the DevOps space.

I'm going to take the existing semver spec in its "Backus–Naur" form, simplify it and adopt it to suit my own needs.

This is what I propose:

```
<valid iac-semver> ::= <version core>
                 | <version core> "-" <patch>
                 | <version core> "+" <state>
                 | <version core> "-" <patch> "+" <state>

<version core> ::= <resource> "." <security> "." <api>

<resource> ::= <numeric identifier>
<security> ::= <numeric identifier>
<api> ::= <numeric identifier>
<patch> ::= <numeric identifier>
<state> ::= "dev" | "tst"

<numeric identifier> ::= "0"
                       | <positive digit>
                       | <positive digit> <digits>

<digits> ::= <digit>
           | <digit> <digits>

<digit> ::= "0"
          | <positive digit>

<positive digit> ::= "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"
```

Broken down, I believe this to mean:

`<resource>`: represents if a breaking change occurs to a resource or there is potential data loss
`<security>`: represents if a security policy will change resulting in a change to the overall security posture
`<api>`: represents if an input or output will change that makes the change backwards incompatible.
`<patch>`: represents if a change to neither of the above occur or is a change that is non-breaking, destructive, doesn't affect the API nor any security related policies
`<state>`: represent if the module's current state is consider in development or in a testing phase. A `<state>` that is undefined is considered production.
I believe with this system a change to an octet is more significant and meaningful, not to mention extremely clear and purposeful when applied to the declarative nature of IAC.

This will also help alleviate how a team decide what the first version tag should be: `v0.1.0`? `v1.0.0`? Instead using this system the rules are simple:

- Does your module create one or more resources? `<resource> = 1`
- Does your module create one or more security policies? `<security> = 1`
- Does your module have any inputs or outputs? `<api> = 1`
- And `<patch>` will always start off as `0`
- Is your module still in development or testing? `<state> = dev | tst`

Based on my experience virtually every Terraform module you write creates one or more resources from the get go, applies some sort of firewall or IAM change and has some inputs or outputs. Therefore a fresh module will very likely have one of the following two versions to kick start its lifecycle:

- `v1.0.1`
- `v1.1.1`

Making a change to the code in that module is then very simple to reflect in the version number:

- Does your change result in a resource being deleted, rebuilt or added? `<resource> + 1`
- Does your change result in a security policy being deleted, updated or added? `<security> + 1`
- Does your change result in an input or output being a updated or deleted? `<api> + 1`
- Does your change have no impact on resources, security policy or the API? `<patch> + 1`
- Does your change need additional development? `<state> = dev`
- Does your change need additional testing? `<state> = tst`

## Resetting Fields

So when do we reset a number back to zero? In the current semver world a major version change resets the minor, patch and other fields to zero (`0`).

Do we need a system like this and what are the deciding factors that determine if a number resets?

I don't believe we do. We simply don't reset the numbers with only one exception - the `<patch>`.

The idea is a number represents a change to a specific type of object in the code that is potentially incompatible with an existing consumer of the code.

Jumping from a `<resource>` of `1` to `4` reflects a big change to a consumer's environment. We're talking about changes that introduce responsibility, costs, maintenance, monitoring, backups, and more. When anything along these lines changes, the consumer has to know.

When an `<api>` changes from `2` to `7`, then you're aware you're going to have to sit up and pay attention before introducing this release into your environment/code base. You're going to have to review the code (changes) to determine how you consume the code and if that's going to work for you.

With regards to resetting the `<patch>` number. I believe this occurs the moment any of the `<version core>` numbers are promoted. For example a promotion from `v1.2.2-3` to `v1.3.2-3` resets the `<patch>` to `0`, resulting in `v1.3.2`.

When the `<version core`> is stable and you're making non-braking changes, then the `<patch>` is incrementing. When the `<version core>` changes, you effectively had a new "release candidate" and the `<patch>` resets.

Resetting these numbers has no meaning in this context. When we're dealing with infrastructure and the declarative (not imperative) nature of IAC the numbers in the version tell a story and demonstrate a module's maturity, or lack of.

## Version Bloat

I don't see a version tag of `12.44.102-2-dev` as a problem in this context.

It's highly descriptive and even if you got to this point you're probably likely to be moving to another Cloud provider, moving towards Kubernetes and or Serverless anyway, which will deprecate your IAC and start you back at `v1.1.1` (or you might be using a fully managed solution.)

In this context a big version number demonstrates the stability of the code base and actually allows us, as engineers, to determine if something is wrong.

For example, if a version tag was `12.44.102-2-dev`, we can start to ask questions like:

- Does this module need to be broken down?
- Is this module too complex?
- Do we need to do a security review? Is the attack surface too big?
- Why is the API so unstable? Do we need to redesign our approach?
- A traditional Semantic Version of `v12.44.102` doesn't tell me any of this. It just tells me a lot is going on, but I don't know what.

## Fresh Eyes

If someone is new to a module and sees a version of `v2.4.12-8` they know several things straight away:

- The resources in the module are relatively stable
- Security updates have been applied to this module over its lifecycle
- The API has changed a lot and that's something to consider when adopting this module - has it stabilised?
- There have been eight patches to this current version that are likely of little concern to me
- I think an example is in order at this point.

## Example Scenario

I have written a Terraform module that builds something simple: a single EC2 Instance with an IAM Instance Policy, Security Group, an additional Elastic Block Storage (EBS) Volume and an Elastic IP (EIP).

My module will take three inputs (for the sake of keeping this simple): one for the instance size, a second for the instance's AMI and the third for the subnet ID.

My module will have an output for the EIP, the instance ID and the Security Group ID. These

Broken down we have the following resources:

- Resource: `aws_instance`
- Resource: `aws_iam_instance_profile`
- Resource: `aws_security_group`
- Resource: `aws_ebs_volume`
- Resource: `aws_eip`

The following inputs:

- Variable: `instance_type`
- Variable: `instance_ami`
- Variable: `instance_subnet_id`

And the following outputs:

-  Output: `eip`
-  Output: `instance_id`
-  Output: `security_group_id`

All the resources obviously fall into the `<resource>` category, so `<resource> = 1` straight away (because using the module means resources are created in your account.)

With have an IAM Instance Profile, too, which is a security related policy and as such pushes `<security>` to `1`.

And we have inputs and outputs, so the `<api>` is pushed to `1` instantly.

The `PATCH` octet will remain unused at this point as we're not patching an existing module as this is the first iteration.

And let's consider our module stable for production and so we're going to leave `<state>` clear.

This means we have a `<version core>` of `v1.1.1`. This is easy to digest: we're creating resources, security related policies or entities, and we provide an API to our module.

With the stage set let's walk through some changes. Each change builds on the previous one for simplicity.

### AMI Change

The AMI ID changes:

Does your change result in a resource being deleted, rebuilt or added?
Yes. `<resource>` + `1` to become `2`.

We release a `<version core>` of `v2.1.1`.

### Tagging Change

We update the EC2 Instance's tags to include a new billing tag and an update to an existing tag.

Does your change have no impact on resources, security policy or the API?
Yes. We release `v2.1.1-1`.

### Dynamic EBS Volume Size

We change the size of the EBS Volume as it has been found to be too small, and we do this by:

- Creating a new input that allows the consumer to define the size
- And setting the default value of the input to an increased version of the original, from `30GB` to `75GB`

For the sake of this example let's say we're unsure of the impact on existing consumers, but we believe the change can be done without rebuilding the existing Volume. We want to run further tests before declaring the module as production ready.

Does your change result in a resource being deleted, rebuilt or added? Although we're not deleting anything and no rebuild takes place, we are adding additional space to the volume, which incurs additional cost.

Secondly we need to test our module first, so we want to signal to others that module is in the testing phase and should not be adopted unless you understand the risks (or are the one doing the testing.)

Now we release `v3.1.2-tst`.

### Tests Successful

After some testing we determine that `v3.1.2-tst` works as expected in multiple scenarios and we publish it as a production ready version: `v3.1.2`.

## What have we discovered?

Let's look at the evolution of the version at this point. The first item in this list is the latest release, with the last being the first:

1. `v3.1.2`
1. `v3.1.2-tst`
1. `v2.1.1`
1. `v1.1.1`

Someone consuming this module at `v2.1.1` and then reviewing the next release would know that `v3.1.2-tst` was a potentially undesirable option for three reasons:

1. The `<resource>` changes from `2` to `3`
1. The `<api>` changes from `1` to `2`, implying my invocation of the module would be invalid as I might not be providing the correct number of inputs
1. The `<state>` has been set to `tst`, implying that further testing is under way

At this point in time, if I were this consumer working with this system, I would review the code's change log or commit history and determine if I'm satisfied with the changes, or I'd wait for `v3.1.2`. I'd test the changes for my self, and deploy them if they worked in my favour.

What this system and this example demonstrates is: I don't have to wonder if a change to the `<major>` number (in the semver) system means: a resource is doing to be rebuilt, the API has changed, a security policy or entity has changed, or some other critical thing I need to now investigate

## To Summarise

I believe we need a new system for versioning IAC code bases.

I'll concede My experience is primarily based on Terraform, but Terraform/HCL is a declarative tool/language. So is CloudFormation. So is Ansible.

We define what we want and the tools make it happen. I don't believe a traditional Semantic Version, which is perfect for software, fits the needs of IAC.