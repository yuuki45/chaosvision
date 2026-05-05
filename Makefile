# CHAOS VISION — common dev commands.
#
# 通常の開発・デプロイで `--dart-define-from-file=secrets.json` を毎回付け忘れない
# ようにするためのラッパー。`make help` で一覧。
#
# 環境変数で挙動を変えたいとき:
#   make run DEVICE=00008110-001E2CDA14F0401E   # 特定の iPhone ID 指定
#   make run DEVICE=macos                       # macOS デスクトップで起動

DEVICE ?= ios
SECRETS = secrets.json
DART_DEFINES = --dart-define-from-file=$(SECRETS)

.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo "CHAOS VISION — make targets"
	@echo ""
	@echo "  Flutter (アプリ側):"
	@echo "    make run               iPhone (or DEVICE=...) で起動 + dart-define"
	@echo "    make run-mac           macOS デスクトップで起動 + dart-define"
	@echo "    make run-onboarding    オンボーディング強制表示モードで起動 (反復テスト用)"
	@echo "    make build-ipa         配布用 IPA をビルド"
	@echo "    make build-ios-debug   Xcode 用に Debug iOS をビルド (Generated.xcconfig 更新)"
	@echo "    make analyze           dart analyze lib/"
	@echo "    make test              flutter test"
	@echo "    make format            dart format ."
	@echo "    make clean             flutter clean"
	@echo ""
	@echo "  Worker (Cloudflare):"
	@echo "    make worker-deploy            wrangler deploy"
	@echo "    make worker-tail              wrangler tail (リアルタイムログ)"
	@echo "    make worker-secret-openai     OPENAI_API_KEY を更新 (対話)"
	@echo "    make worker-secret-app        APP_SECRET を更新 (対話)"
	@echo "    make worker-secrets-list      登録済み secret 一覧"
	@echo "    make worker-whoami            Cloudflare ログイン状態確認"
	@echo ""
	@echo "  その他:"
	@echo "    make secrets-bootstrap   secrets.json を example から作成"
	@echo "    make tail                make worker-tail と同じ (短縮)"

# ─── secrets.json check ─────────────────────────────────────────────
.PHONY: check-secrets
check-secrets:
	@test -f $(SECRETS) || ( \
		echo "❌ $(SECRETS) が無い。"; \
		echo "   make secrets-bootstrap で雛形を作成 → 値を埋めてください。"; \
		exit 1 \
	)

.PHONY: secrets-bootstrap
secrets-bootstrap:
	@if [ -f $(SECRETS) ]; then \
		echo "ℹ️  $(SECRETS) は既に存在します。上書きしません。"; \
	else \
		cp secrets.json.example $(SECRETS); \
		echo "✅ $(SECRETS) を作成しました。CHAOS_WORKER_URL と CHAOS_APP_SECRET を編集してください。"; \
	fi

# ─── Flutter ────────────────────────────────────────────────────────
.PHONY: run
run: check-secrets
	flutter run -d $(DEVICE) $(DART_DEFINES)

.PHONY: run-mac
run-mac: check-secrets
	flutter run -d macos $(DART_DEFINES)

# 実機でオンボーディングを毎回確認したいとき用。
# FORCE_ONBOARDING=true を渡すと:
#   - 起動時、保存済み first_launch フラグを無視して常にオンボを表示
#   - オンボ完了時にも first_launch=false を書き込まないので、
#     アプリを終了して再起動してもまたオンボから始まる。
.PHONY: run-onboarding
run-onboarding: check-secrets
	flutter run -d $(DEVICE) $(DART_DEFINES) --dart-define=FORCE_ONBOARDING=true

.PHONY: build-ipa
build-ipa: check-secrets
	flutter build ipa $(DART_DEFINES)

.PHONY: build-ios-debug
build-ios-debug: check-secrets
	flutter build ios --debug --no-codesign $(DART_DEFINES)
	@echo ""
	@echo "✅ Generated.xcconfig に DART_DEFINES を焼き込みました。"
	@echo "   この後 Xcode で ▶ Run しても Worker URL / APP_SECRET が伝播します。"

.PHONY: analyze
analyze:
	dart analyze lib/

.PHONY: test
test:
	flutter test

.PHONY: format
format:
	dart format .

.PHONY: clean
clean:
	flutter clean

# ─── Worker (Cloudflare) ────────────────────────────────────────────
.PHONY: worker-deploy
worker-deploy:
	cd worker && npx wrangler deploy

.PHONY: worker-tail tail
worker-tail tail:
	cd worker && npx wrangler tail

.PHONY: worker-secret-openai
worker-secret-openai:
	cd worker && npx wrangler secret put OPENAI_API_KEY

.PHONY: worker-secret-app
worker-secret-app:
	cd worker && npx wrangler secret put APP_SECRET

.PHONY: worker-secrets-list
worker-secrets-list:
	cd worker && npx wrangler secret list

.PHONY: worker-whoami
worker-whoami:
	cd worker && npx wrangler whoami
