> [Go Home](../iac-labs.md)

# Objective: Explore the basics of configuration management and automation.

## Assignments:

-   File Deployment:
    -   Write a script to deploy a configuration file to a specific directory on multiple servers.

---

> For this assignment, I am using my **Ubuntu 24.04 WSL2** machine as the control node.

> And for the Manged host, I am creating an _Azure VM_ with **Ubuntu 22.04 server** OS.

---

### Prerequisites:

-   create a Inventory file with ip address of the managed host and username

![inventory file](image-3.png)

### Task 1: Check Ansible installation and version on control node.

```bash
ansible --version
```

![ansible version](image.png)

### Task 2: Check ssh connection to control node

```bash
ssh ansible_node@<VM-IP>
```

![ssh connection](image-1.png)

### Task 3: Create a Playbook to create a file on control node.

```bash
vim create-file.yml
# then
cat create-file.yml
```

![create file playbook](image-2.png)

### Task 4: Run the playbook

```bash
ansible-playbook create-file.yml
```

![run playbook](image-4.png)

---

> Now, let's move to the managed host.

-   let's check if file is created on the managed host.

![managed host tmp](image-5.png)

-   As we can see the file is created on the managed host at `/tmp` directory.

---

-   Now let's modify the playbook to add content to this file.

![alt text](image-8.png)

-   Now let's run the playbook again.

![alt text](image-9.png)

-   lets check the content of the file on the managed host.

![alt text](image-10.png)

> and the content is present on the managed host.

---
