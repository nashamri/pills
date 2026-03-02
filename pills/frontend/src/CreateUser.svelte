<script>
	import { createEventDispatcher } from 'svelte'
	import { CreateUser } from '../wailsjs/go/main/App.js'

	const dispatch = createEventDispatcher()

	const initialForm = {
		id: 0,
		firstName: '',
		lastName: '',
		userName: '',
		email: '',
		password: '',
		gender: 'Male',
		role: 1
	}

	let form = { ...initialForm }
	let loading = false
	let error = ''

	async function submit() {
		error = ''

		if (!form.firstName.trim() || !form.userName.trim() || !form.email.trim()) {
			error = 'First name, username and email are required.'
			return
		}

		loading = true
		try {
			const created = await CreateUser({ ...form })
			dispatch('created', created)
			form = { ...initialForm }
		} catch (e) {
			error = e?.message || String(e)
		} finally {
			loading = false
		}
	}
</script>

<section class="card">
	<h2>Create User</h2>

	{#if error}
		<p class="error">{error}</p>
	{/if}

	<form class="grid" on:submit|preventDefault={submit}>
		<label>
			First Name *
			<input bind:value={form.firstName} type="text" />
		</label>

		<label>
			Last Name
			<input bind:value={form.lastName} type="text" />
		</label>

		<label>
			Username *
			<input bind:value={form.userName} type="text" />
		</label>

		<label>
			Email *
			<input bind:value={form.email} type="email" />
		</label>

		<label>
			Password
			<input bind:value={form.password} type="password" />
		</label>

		<label>
			Gender
			<select bind:value={form.gender}>
				<option value="Male">Male</option>
				<option value="Female">Female</option>
				<option value="Other">Other</option>
			</select>
		</label>

		<label>
			Role
			<select bind:value={form.role}>
				<option value={0}>Admin</option>
				<option value={1}>Patient</option>
				<option value={2}>Caregiver</option>
			</select>
		</label>

		<div class="actions">
			<button type="submit" disabled={loading}>{loading ? 'Saving...' : 'Create User'}</button>
		</div>
	</form>
</section>

<style>
	.card {
		background: rgba(255, 255, 255, 0.08);
		border: 1px solid rgba(255, 255, 255, 0.1);
		border-radius: 12px;
		padding: 1rem;
		margin-bottom: 1rem;
		text-align: left;
	}

	h2 {
		margin: 0 0 1rem;
	}

	.grid {
		display: grid;
		grid-template-columns: repeat(2, minmax(0, 1fr));
		gap: 0.75rem;
	}

	label {
		display: flex;
		flex-direction: column;
		gap: 0.35rem;
		font-size: 0.9rem;
	}

	input,
	select,
	button {
		border: 1px solid rgba(255, 255, 255, 0.2);
		border-radius: 8px;
		padding: 0.55rem 0.7rem;
		background: rgba(255, 255, 255, 0.9);
		color: #1b2636;
		font: inherit;
	}

	.actions {
		grid-column: 1 / -1;
	}

	button {
		cursor: pointer;
		background: #6da8ff;
		border-color: #6da8ff;
		color: #fff;
		font-weight: 600;
	}

	.error {
		color: #ff9da1;
		margin: 0 0 0.8rem;
	}
</style>
