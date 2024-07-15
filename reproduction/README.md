# Reproduction README

<!-- TODO: Remove this warning once filled out README -->
**Please note: This is a template README and has not yet been completed**

<!-- TODO: Fill out the README -->
## Model summary

> Huang S, Maingard J, Kok HK, Barras CD, Thijs V, Chandra RV, Brooks DM and Asadi H. **Optimizing Resources for Endovascular Clot Retrieval for Acute Ischemic Stroke, a Discrete Event Simulation**. *Frontiers in Neurology* 10, 653 (2019). <https://doi.org/10.3389/fneur.2019.00653>.

This is a discrete-event simulation model of an endovascular clot retrieval (ECR) service. ECR is a treatment for acute ischaemic stroke. The model includes the stroke pathway, as well as three other pathways that share resources with the stroke pathway: an elective non-stroke interventional neuroradiology pathway, an emergency interventional radiology pathway, and an elective interventional radiology pathway.

The model is created using R Simmer.

The paper explores waiting times and resource utilisation - particularly focussing on the biplane angiographic suite (angioINR). A few scenarios are tried to help examine why the wait times are so high for the angioINR.

Model structure from Huang et al. 2019:

![Process flow diagram from Huang et al. 2019](../original_study/fig1.jpg)

## Scope of the reproduction

In this assessment, we attempted to reproduce 8 items: 5 figures and 3 in-text results. 

## Reproducing these results

### Repository overview

TBC <!-- Add overview once tidied -->

### Step 1. Set up environment

TBC <!-- Add steps -->

### Step 2. Running the model

TBC <!-- Add steps -->

## Reproduction specs and runtime

This reproduction was conducted on an Intel Core i7-12700H with 32GB RAM running Ubuntu 22.04.4 Linux.

Expected model runtime is <!-- Add run time-->.

## Citation

To cite the original study, please refer to the reference above. To cite this reproduction, please refer to the CITATION.cff file in the parent folder.

## License

This repository is licensed under the GNU GPL-3.0 license.
