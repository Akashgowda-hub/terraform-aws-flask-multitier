// Replace this with the ALB DNS name after deploying the backend.
const API_BASE = "http://REPLACE_WITH_ALB_DNS";

const form = document.getElementById("todo-form");
const titleInput = document.getElementById("todo-title");
const todoList = document.getElementById("todo-list");
const statusMessage = document.getElementById("status");

async function apiRequest(path, options = {}) {
    const response = await fetch(`${API_BASE}${path}`, {
        ...options,
        headers: {
            "Content-Type": "application/json",
            ...options.headers
        }
    });

    if (!response.ok) {
        throw new Error(`Request failed: HTTP ${response.status}`);
    }

    return response.status === 204 ? null : response.json();
}

function showError(error) {
    statusMessage.textContent = error.message;
}

function renderTodos(todos) {
    todoList.replaceChildren();

    if (todos.length === 0) {
        statusMessage.textContent = "No todos yet. Add your first task!";
        return;
    }

    statusMessage.textContent = `${todos.length} todo(s)`;

    for (const todo of todos) {
        const item = document.createElement("li");
        const title = document.createElement("span");
        const deleteButton = document.createElement("button");

        // Use textContent to display user input safely.
        title.textContent = todo.title;

        deleteButton.textContent = "Delete";
        deleteButton.className = "delete-button";
        deleteButton.addEventListener("click", async () => {
            try {
                await apiRequest(`/api/todos/${todo.id}`, {
                    method: "DELETE"
                });
                await loadTodos();
            } catch (error) {
                showError(error);
            }
        });

        item.append(title, deleteButton);
        todoList.appendChild(item);
    }
}

async function loadTodos() {
    try {
        statusMessage.textContent = "Loading todos...";
        const todos = await apiRequest("/api/todos");
        renderTodos(todos);
    } catch (error) {
        showError(error);
    }
}

form.addEventListener("submit", async (event) => {
    event.preventDefault();

    const title = titleInput.value.trim();
    if (!title) return;

    try {
        await apiRequest("/api/todos", {
            method: "POST",
            body: JSON.stringify({ title })
        });

        titleInput.value = "";
        await loadTodos();
    } catch (error) {
        showError(error);
    }
});

// Load the initial list when the page opens.
loadTodos();
