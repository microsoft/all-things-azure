# 🌐 All Things Azure

[![GitHub Stars](https://img.shields.io/github/stars/microsoft/all-things-azure?style=social)](https://github.com/microsoft/all-things-azure/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/microsoft/all-things-azure?style=social)](https://github.com/microsoft/all-things-azure/network/members)
[![GitHub Contributors](https://img.shields.io/github/contributors/microsoft/all-things-azure)](https://github.com/microsoft/all-things-azure/graphs/contributors)
[![License: MIT](https://img.shields.io/github/license/microsoft/all-things-azure)](./LICENSE)

## Introduction

**All Things Azure** is a Microsoft Developer Blog series focusing on developer how-tos, use cases, and solutions on Microsoft Azure. This repository serves as the companion to the blog posts on *All Things Azure*, providing sample code, demos, and resources that complement the articles. Many blog posts in *All Things Azure* link to this repo for hands-on examples, enabling readers to explore the concepts discussed in the articles in a practical way.

## Repository Purpose

- **💡 Blog Companion** – The content here directly **complements the [All Things Azure blog](https://devblogs.microsoft.com/all-things-azure/)**. Each folder or file in this repository corresponds to one or more blog posts, offering code and configurations as an extension of the written tutorials.
- **🛠️ Sample Code & Demos** – You’ll find working sample projects, scripts, and demonstrations for various Azure scenarios (AI, app development, DevOps, cloud architecture, and more). These examples are intended to help you jump-start your own projects by showing how to implement solutions described on the blog.
- **📁 Resources & Guides** – In some cases, the repository includes detailed guides or configuration files referenced in the blog. For instance, if a blog post outlines a solution, the accompanying content here might include deployment templates, code notebooks, or configuration YAML/JSON to replicate that solution.

## 🔗 Related Blog Posts and Samples

Below are a few featured blog posts from *All Things Azure* and the corresponding resources available in this repository. We highly recommend reading the blog posts for full context, then using this repo to dive into the implementation:

- **Agentic AI Explained: A Philosophical Framework for Understanding AI Agents** – *(All Things Azure blog post by David Barkol)*. This article explores how to create AI agents with personas inspired by philosophers.  
  📌 *Code Sample*: See the [`agentic-philosophers/`](./agentic-philosophers) folder for the sample implementation. It contains code (using Semantic Kernel) to bring Socrates, Plato, and Aristotle agent personas to life. *(Read the blog post here for background: [Agentic AI Explained](https://devblogs.microsoft.com/all-things-azure/agentic-philosophers/).)*

- **Multi-Cluster Layer 4 Load Balancing with Azure Fleet Manager** – *(All Things Azure blog post by Diogo Casati)*. This guide shows how to set up cross-cluster layer-4 load balancing for Azure Kubernetes Service (AKS) using Fleet Manager, improving high availability and traffic distribution across multiple clusters.  
  📌 *Guide*: Refer to the markdown guide [`multi-cluster-layer-4-load-balancing-with-fleet-manager.md`](./multi-cluster-layer-4-load-balancing-with-fleet-manager.md) in this repo. It provides step-by-step configuration details and code snippets for implementing the multi-cluster load balancer as described in the blog. *(Read the full article on the blog for conceptual background and context.)*

- **Project Stormbreaker – Running HPC Simulations on AKS** – *(Upcoming All Things Azure post by the App Dev GBB Team)*. This example demonstrates deploying and running heavy simulation models (e.g., ADCIRC/SWAN for coastal simulations) on Azure Kubernetes Service using Terraform and containerized workloads.  
  📌 *Resources*: Check out the [`project-stormbreaker/`](./project-stormbreaker) directory for Terraform scripts, Kubernetes manifests, and documentation to reproduce the simulation environment. These resources correspond to the blog’s scenario of running complex **HPC workloads on Azure** at scale, enabling you to follow along with the deployment steps.

- **Visualize ROI of GitHub Copilot Usage** – *(All Things Azure blog post by Xuefeng Yin)*. This guide explains how to visualize the return on investment (ROI) of using GitHub Copilot in your projects.  
  📌 *Submodule*: The [`visualize-roi-of-ghcp-usage`](https://github.com/satomic/copilot-usage-advanced-dashboard) directory is a submodule pointing to the original repository. It contains tools and dashboards to help you measure and visualize the impact of GitHub Copilot on your development workflow. *(Read the full article on the blog for detailed instructions and insights.)*

> **Note:** More samples will be added over time as new posts are published on the *All Things Azure* blog. Be sure to watch ★ this repository for updates. We aim to keep the code up-to-date with Azure’s evolving services and best practices.

## 🚀 Getting Started 

1. **Browse the Blog** – Visit the [All Things Azure blog](https://devblogs.microsoft.com/all-things-azure/) and find a post that interests you. Each post provides the background, problem scenario, and a walkthrough of the solution.
2. **Clone the Repo** – Grab the code by cloning this repository: `git clone https://github.com/microsoft/all-things-azure.git`. You can also download it as a ZIP if you prefer.
3. **Find the Relevant Folder** – Locate the folder or file in the repo that matches the blog post. (The names are usually similar to the blog title or topic, as listed above.) Inside, you’ll find the sample code, scripts, or configuration files referenced in the article.
4. **Read Instructions** – Many sample folders include their own README or comments to help you run the code. Make sure to read any provided instructions. The blog post itself often serves as a guide, so keep it open for reference.
5. **Run and Explore** – Follow the steps to deploy or execute the sample in your Azure environment. You may need an Azure subscription and certain Azure services enabled (the blog post will mention prerequisites). Feel free to experiment with the code and adapt it to your needs.
6. **Provide Feedback** – If something doesn’t work as expected or you have ideas for improvement, let us know! You can open an issue in this repo or comment on the blog post. Collaboration is welcome.

## 🤝 Contributing

We welcome contributions to enhance the samples or add new ones! If you have a fix or a new example to share, please open a pull request. Before contributing, review the following:

- **Contributor License Agreement (CLA)** – For any significant contributions, you'll be prompted to sign a CLA, per the Microsoft Open Source guidelines. This is an electronic form to ensure you agree to the terms. (You only need to do this once for all Microsoft repos.) More details here: [Microsoft CLA](https://cla.opensource.microsoft.com).
- **Code of Conduct** – Please read and respect our [Code of Conduct](./CODE_OF_CONDUCT.md). We adhere to the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct), and we expect all contributors to do the same. Let's keep our community respectful and inclusive.
- **Project Support** – See [SUPPORT.md](./SUPPORT.md) for how to get help or report issues. You can use GitHub Issues to report bugs or suggest enhancements.

When submitting a PR, make sure to detail the purpose of the change and which blog post (if any) it relates to. This helps the maintainers review and integrate it more easily. 🎉

## 📫 Support & Feedback

If you need help with a sample or have questions:

- **Blog Comments** – The fastest way might be to ask on the blog post itself. Authors and the community might respond with guidance.
- **GitHub Issues** – Feel free to open an [issue](https://github.com/microsoft/all-things-azure/issues) in this repository. We’ll do our best to respond in a timely manner.
- **Email/Contact** – If the blog or repo points to a contact (e.g., via a Microsoft alias or contact form), you can reach out that way for specific queries. (Check the blog’s footer or the SUPPORT.md for contact info.)

We appreciate feedback! It helps us improve both the blog content and the sample code here.

## 🔒 License

All code in this repository is released under the [MIT License](./LICENSE). This means you are free to use, modify, and distribute the samples in your own projects. We kindly ask that you include a reference back to this repo or the All Things Azure blog when using significant portions of the code, so others can find the original source. 

## 🙏 Acknowledgments

This repository is maintained by the contributors of the **All Things Azure** blog – a team of Microsoft Cloud Advocates, Azure Global Black Belt engineers, and other Azure experts. The goal is to share real-world Azure solutions with the developer community in an open and collaborative way. 

Special thanks to all the blog post authors and code contributors who have made this content possible. Each sample includes attribution to its original author(s) where applicable. We’re excited to see the community build upon these examples and create even more amazing Azure solutions.

Happy Azure coding! ☁️🚀 Read the latest from **All Things Azure** on the [official blog](https://devblogs.microsoft.com/all-things-azure/) and feel free to join the conversation there. 

