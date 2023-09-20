# Practice
A practice consists of a collection of principles, hisotircal context, and users whom would benefit in sharing knowledge with one another. Whether that to further a companies service offering, or for uplifting the quality of the service. Practices are organized in the top level of the repository, with the initial set of practices defined: `hardware/`, `net-eng/`, `soft-eng/`, and `sys-eng/`. 

# Document Types
- *Conceptual* - Documents where the main theme is that of abstract concepts regarding the practice. The `abstract/` folders found in each practice are where conceptual document types are to be placed. There can be "exceptions" to this; where conceptual documents are more sensible to be categorized as implementation or informational document types. Conceptual documents talk about things such as Architecture, Design, Buisness Requirements, Software Requirements, and Technology at an abstract level.
- *Implementation* - Documents where the main theme is speaking about the requirements and the execution of building an environment - whether that be for networks to storage clusters. These types of document would include a write up of requirements, and a step by step guide on how to build the environment. Bonus if the concepts and requirements are tied to known concepts in the `abstract/`. folder. 
- *Informational* - Documents where it is strictly informational in nature and may change due to the specifics of the information provided. This drives into the details of operations, such as: log messages, security vulnerabilities, the manifestation of a software bug, and so on. Information document types merely suggest specifics such as the details you would find in a PR or a KB article.

# Templates

All documents types are to start with a basic header table, e.g

Title | The Title
--- | ---
Contributor | First Last [@daniel-hurley](https://github.com/daniel-hurley/)
Date | 07-17-2023

and in Markdown:
```
Title | The Title
--- | ---
Contributor | First Last [@daniel-hurley](https://github.com/daniel-hurley/)
Date | 07-17-2023
```

Based upon the document type, the document may include more information such as a Security Advisory, Problem Report, or references to other material external to the repository. This is not specifically currated in this repostiory, and is adviseable to provide references where needed through the document in the relevant table or in the document body itself. Specific templates can be found in the `format/templates/` folder as specific use cases are documented through the lifecycle of the repository.

# Start Document

The `start.md` document can be found in every folder. The purpose of the start document is to give a briefer on the layout of the file structure and provide useful reference links to navigate the file structure and associated content. This becomes very important as the repository grows.
