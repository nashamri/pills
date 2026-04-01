import { writable } from 'svelte/store'
import { push } from 'svelte-spa-router';


export const currentUser = writable(null)

currentUser.set({ name: 'Fahad', age: 22 })


export function logout() {
    push('/welcome')
    currentUser.set(null)
}