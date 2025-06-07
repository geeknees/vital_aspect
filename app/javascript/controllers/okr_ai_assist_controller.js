import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['objectiveField']

  generate() {
    const objective = this.objectiveFieldTarget.value.trim()
    if (objective === '') return

    fetch(this.data.get('url'), {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ objective })
    })
      .then(res => res.json())
      .then(data => {
        data.forEach(title => {
          window.dispatchEvent(new CustomEvent('okr-ai:add-key-result', { detail: { title } }))
        })
      })
  }
}
