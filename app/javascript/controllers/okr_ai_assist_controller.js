import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['objectiveField']
  static values = { url: String }

  connect() {
    console.log('OKR AI Assist controller connected')
    console.log('URL value:', this.urlValue)
    console.log('Has objectiveField target:', this.hasObjectiveFieldTarget)
  }

  generate() {
    console.log('AIアシスト generate() method called')

    // Check if objectiveField target exists
    if (!this.hasObjectiveFieldTarget) {
      console.error('objectiveField target not found')
      alert('目標タイトルフィールドが見つかりません')
      return
    }

    const objective = this.objectiveFieldTarget.value.trim()
    console.log('Objective value:', objective)

    if (objective === '') {
      alert('目標タイトルを入力してください')
      return
    }

    // Show loading state
    const button = event.target
    const originalText = button.innerHTML
    button.innerHTML = '<i class="fas fa-spinner fa-spin mr-2"></i>生成中...'
    button.disabled = true

    console.log('Sending request to:', this.urlValue)

    fetch(this.urlValue, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')
          .content
      },
      body: JSON.stringify({ objective })
    })
      .then((res) => {
        console.log('Response status:', res.status)
        if (!res.ok) {
          throw new Error(`ネットワークエラー: ${res.status}`)
        }
        return res.json()
      })
      .then((data) => {
        console.log('AI response data:', data)
        data.forEach((title) => {
          window.dispatchEvent(
            new CustomEvent('okr-ai:add-key-result', { detail: { title } })
          )
        })
      })
      .catch((error) => {
        console.error('Error:', error)
        alert(`Key Resultsの生成に失敗しました: ${error.message}`)
      })
      .finally(() => {
        // Restore button state
        button.innerHTML = originalText
        button.disabled = false
      })
  }
}
