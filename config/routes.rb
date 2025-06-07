Rails.application.routes.draw do
  scope "(:locale)", locale: /en|ja/ do
    resource :session
    resources :passwords, param: :token
    resource :user, only: %i[ edit update ]

    # ダッシュボード
    get "dashboard", to: "dashboard#index"

    # 組織管理
    resources :organizations do
      resources :memberships do
        member do
          patch :accept
          delete :decline
        end
      end

      # 360度評価管理
      resources :evaluations do
        member do
          patch :start
          patch :complete
          get :results   # 評価結果確認画面
        end

        # 質問管理
        resources :questions do
          collection do
            patch :reorder
          end
        end

        # 参加者管理
        resources :evaluation_participants, path: "participants" do
          collection do
            post :bulk_create
          end
        end

        # 評価回答
        resources :evaluation_responses, path: "responses" do
          collection do
            get :participate  # 参加者の回答画面
            patch :submit     # 回答の一括提出
          end
        end
      end

      # OKR管理
      resources :okrs do
        member do
          patch :activate # ドラフトからアクティブへ変更
        end
        collection do
          post :suggest_key_results
        end
        resources :okr_progresses, path: "progresses"
      end
    end

    # Defines the root path route ("/")
    root "dashboard#index"
  end

  # Default redirect to Japanese
  get "/", to: redirect("/ja")

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
