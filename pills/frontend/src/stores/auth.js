import { writable } from 'svelte/store'
import { push } from 'svelte-spa-router';
import { Login as DBLogin } from '../../wailsjs/go/main/App.js';

export const currentUser = writable(null)

export async function login(email, password) {
    const user = await DBLogin(email, password);
    currentUser.set(user);
    console.log(user)
    push('/');
    return user;
}

export function logout() {
    currentUser.set(null);
    push('/welcome');
}
