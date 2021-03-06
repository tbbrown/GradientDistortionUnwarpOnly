#GradientDistortionUnwarpOnly

## Script Description

The <code>GradientDistortionUnwarpOnly.sh</code> script performs "only" Gradient Distortion 
Correction for unprocessed images found in the <code>_unproc</code> resources for a 
specified [Human Connectome Project][HCP] (HCP) project and subject in ConnectomeDB.
This script was written for the "unprocessed" data release for the LifeSpan
Phase 1a project. LifeSpan is a potential long-term follow up project to the 
[HCP][HCP]

The associated <code>BatchUnwarp.sh</code> script is an example of a way to submit a 
batch of such unwarping jobs to a Sun/Oracle Grid Engine.

Both the <code>GradientDistortionUnwarpOnly.sh</code> script and the associated 
<code>BatchUnwarp.sh</code> script should be run from a machine that has access
to the HCP external (ConnectomeDB) file system (e.g. an hcpx* machine).

The <code>GradientDistortionUnwarpScansOnly.sh</code> script performs similar Gradient
Distortion Correction only for images found in the <code>SCANS/&lt;scan-number&gt;/NIFTI 
subdirectories in an [HCP][HCP] IntraDB project. This script was written to perform
Gradient Distortion Correction on scans of a phantom.

The associated <code>UnwarpPhantom.sh</code> script submits a 
<code>GradientDistortionUnwarpScansOnly.sh</code> job to the Sun/Oracle Grid Engine
to unwarp some collected phantom data.

Both the <code>GradientDistortionUnwarpScansOnly.sh</code> script and the associated
<code>UnwarpPhantom.sh</code> script should be run from a machine that has access
to the HCP internal (IntraDB) file system (e.g. an hcpi* machine).

<!-- References -->
[HCP]: http://www.humanconnectome.org


