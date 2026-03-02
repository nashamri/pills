<script>
	import { GetAllUsers, UpdateUser, DeleteUser } from '../wailsjs/go/main/App.js'

	export let refreshKey = 0

	let users = []
	let loading = false
	let error = ''

	let editingId = null
	let editForm = null
	let lastRefreshKey = -1

	$: if (refreshKey !== lastRefreshKey) {
		lastRefreshKey = refreshKey
		loadUsers()
	}

	async function loadUsers() {
		loading = true
		error = ''
		try {
			users = await GetAllUsers()
		} catch (e) {
			error = e?.message || String(e)
		} finally {
			loading = false
		}
	}

	function startEdit(user) {
		editingId = user.id
		editForm = { ...user }
	}

	function cancelEdit() {
		editingId = null
		editForm = null
	}

	async function saveEdit() {
		if (!editForm) return
		try {
			await UpdateUser(editForm)
			await loadUsers()
			cancelEdit()
		} catch (e) {
			error = e?.message || String(e)
		}
	}

	async function removeUser(id) {
		const confirmed = confirm('Are you sure you want to delete this user?')
		if (!confirmed) return

		try {
			await DeleteUser(id)
			await loadUsers()
		} catch (e) {
			error = e?.message || String(e)
		}
	}

	function roleLabel(role) {
		if (role === 0) return 'Admin'
		if (role === 1) return 'Patient'
		if (role === 2) return 'Caregiver'
		return String(role)
	}
</script>

<section class="card">
	<h2>Users</h2>

	{#if error}
		<p class="error">{error}</p>
	{/if}

	{#if loading}
		<p>Loading users...</p>
	{:else if users.length === 0}
		<p>No users found.</p>
	{:else}
		<table>
			<thead>
				<tr>
					<th>ID</th>
					<th>First Name</th>
					<th>Last Name</th>
					<th>Username</th>
					<th>Email</th>
					<th>Gender</th>
					<th>Role</th>
					<th>Actions</th>
				</tr>
			</thead>
			<tbody>
				{#each users as user}
					<tr>
						<td>{user.id}</td>

						{#if editingId === user.id}
							<td><input bind:value={editForm.firstName} /></td>
							<td><input bind:value={editForm.lastName} /></td>
							<td><input bind:value={editForm.userName} /></td>
							<td><input bind:value={editForm.email} type="email" /></td>
							<td>
								<select bind:value={editForm.gender}>
									<option value="Male">Male</option>
									<option value="Female">Female</option>
									<option value="Other">Other</option>
								</select>
							</td>
							<td>
								<select bind:value={editForm.role}>
									<option value={0}>Admin</option>
									<option value={1}>Patient</option>
									<option value={2}>Caregiver</option>
								</select>
							</td>
							<td class="actions">
								<button class="ok" on:click={saveEdit}>Save</button>
								<button class="ghost" on:click={cancelEdit}>Cancel</button>
							</td>
						{:else}
							<td>{user.firstName}</td>
							<td>{user.lastName}</td>
							<td>{user.userName}</td>
							<td>{user.email}</td>
							<td>{user.gender}</td>
							<td>{roleLabel(user.role)}</td>
							<td class="actions">
								<button class="ok" on:click={() => startEdit(user)}>Edit</button>
								<button class="danger" on:click={() => removeUser(user.id)}>Delete</button>
							</td>
						{/if}
					</tr>
				{/each}
			</tbody>
		</table>
	{/if}
</section>

<style>
	.card {
		background: rgba(255, 255, 255, 0.08);
		border: 1px solid rgba(255, 255, 255, 0.1);
		border-radius: 12px;
		padding: 1rem;
		text-align: left;
	}

	h2 {
		margin: 0 0 1rem;
	}

	table {
		width: 100%;
		border-collapse: collapse;
		font-size: 0.9rem;
	}

	th,
	td {
		border-bottom: 1px solid rgba(255, 255, 255, 0.15);
		padding: 0.5rem;
		vertical-align: middle;
	}

	input,
	select,
	button {
		border: 1px solid rgba(255, 255, 255, 0.2);
		border-radius: 8px;
		padding: 0.45rem 0.55rem;
		background: rgba(255, 255, 255, 0.9);
		color: #1b2636;
		font: inherit;
	}

	.actions {
		display: flex;
		gap: 0.4rem;
	}

	button {
		cursor: pointer;
	}

	.ok {
		background: #6da8ff;
		color: white;
		border-color: #6da8ff;
	}

	.danger {
		background: #ff5f72;
		color: white;
		border-color: #ff5f72;
	}

	.ghost {
		background: transparent;
		color: white;
	}

	.error {
		color: #ff9da1;
		margin: 0 0 0.8rem;
	}
</style>
