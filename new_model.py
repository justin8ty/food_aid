import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split, cross_val_score, KFold
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, mean_absolute_error
import matplotlib.pyplot as plt
import json

# -----------------------------
# 1. Load Data and Reset Index, Fix State Column
# -----------------------------
df = pd.read_csv('./malaysia_need_score_dataset.csv')
df.reset_index(drop=True, inplace=True)

# Convert relevant columns to numeric (if not already)
numeric_cols = [
    'poverty_absolute', 'income_mean', 'gini', 
    'unemployement_rate', 'participation_rate', 'population', 
    'expenditure_mean'
]
for col in numeric_cols:
    df[col] = pd.to_numeric(df[col], errors='coerce')

# -----------------------------
# 2. Feature Engineering
# -----------------------------
# 2.a Compute poverty_rate as a percentage
df['poverty_rate'] = (df['poverty_absolute'] / df['population']) * 100

# 2.b Normalize income_mean (scale 0 to 1)
df['income_normalized'] = (df['income_mean'] - df['income_mean'].min()) / (df['income_mean'].max() - df['income_mean'].min())

# 2.c Normalize population (scale 0 to 1)
df['population_normalized'] = (df['population'] - df['population'].min()) / (df['population'].max() - df['population'].min())

# 2.d Compute expenditure_to_income_ratio
df['expenditure_to_income_ratio'] = df['expenditure_mean'] / df['income_mean']

# 2.e Normalize unemployement_rate (assuming percentage values) and participation_rate
df['unemployment_rate_norm'] = df['unemployement_rate'] / 100
df['participation_rate_norm'] = df['participation_rate'] / 100

# 2.f Compute final need metric score using our chosen weights:
#     calc_need_score = (poverty_rate * 0.35) +
#                       (expenditure_to_income_ratio * 0.2) +
#                       ((1 - income_normalized) * 0.15) +
#                       (unemployment_rate_norm * 0.15) +
#                       ((1 - participation_rate_norm) * 0.05) +
#                       (population_normalized * 0.1)
df['need_metric_score'] = (
    df['poverty_rate'] * 0.35 +
    df['expenditure_to_income_ratio'] * 0.2 +
    ((1 - df['income_normalized']) * 0.15) +
    (df['unemployment_rate_norm'] * 0.15) +
    ((1 - df['participation_rate_norm']) * 0.05) +
    (df['population_normalized'] * 0.1)
)

# -----------------------------
# 3. Define Final Features and Target
# -----------------------------
# We select features for regression based on our calculated fields
features = ['poverty_rate', 'expenditure_to_income_ratio', 'income_normalized', 'population_normalized', 'unemployment_rate_norm', 'participation_rate_norm']
target = 'need_metric_score'

# Remove rows with missing values in features or target
df.dropna(subset=features + [target], inplace=True)

# -----------------------------
# 4. Categorize Need Urgency and Summarize
# -----------------------------
def categorize(score):
    if score >= 0.33:
        return "high"
    elif score >= 0.30:
        return "moderate"
    else:
        return "low"

df['urgency'] = df[target].apply(categorize)

print("🧾 Summary of States with Need Score & urgency:")
print(df[['state', target, 'urgency']].sort_values(by=target, ascending=False).to_string(index=False))

# -----------------------------
# 5. Split Data and Normalize Features
# -----------------------------
X = df[features]
y = df[target]

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# -----------------------------
# 6. Train the Linear Regression Model
# -----------------------------
model = LinearRegression()
model.fit(X_train_scaled, y_train)
print("\n✅ Model training completed!")

# -----------------------------
# 7. Evaluate the Model
# -----------------------------
cv = KFold(n_splits=5, shuffle=True, random_state=42)
cv_scores = cross_val_score(model, scaler.transform(X), y, scoring='neg_mean_absolute_error', cv=cv)
print(f"📊 Cross-Validated MAE: {-np.mean(cv_scores):.4f}")

y_pred = model.predict(X_test_scaled)
mse = mean_squared_error(y_test, y_pred)
mae = mean_absolute_error(y_test, y_pred)

print("\n📉 Test Set Evaluation:")
print(f"   Mean Squared Error: {mse:.4f}")
print(f"   Mean Absolute Error: {mae:.4f}")

# -----------------------------
# 8. Show Predictions with State Names
# -----------------------------
pred_df = pd.DataFrame({
    'state': df.loc[X_test.index, 'state'],
    'Actual': y_test,
    'Predicted': y_pred
})
print("\n🔍 Sample Predictions:")
print(pred_df.sort_values(by='Actual', ascending=False).to_string(index=False))
pred_df.to_csv("predictions.csv", index=False)

# -----------------------------
# 9. Visualization
# -----------------------------
plt.figure(figsize=(8, 5))
plt.scatter(y_test, y_pred, alpha=0.7, color="skyblue")
plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'r--')
plt.xlabel("Actual Need Score")
plt.ylabel("Predicted Need Score")
plt.title("Actual vs Predicted Need Score")
plt.grid(True)
plt.tight_layout()
plt.show()

plt.figure(figsize=(8, 5))
plt.hist(y_test - y_pred, bins=20, color="salmon", alpha=0.7)
plt.axvline(0, color='black', linestyle='dashed')
plt.title("Residual Error Distribution")
plt.xlabel("Residual")
plt.ylabel("Frequency")
plt.grid(True)
plt.tight_layout()
plt.show()

# -----------------------------
# 10. Transform Final Results into JSON for Google Maps Integration
# -----------------------------
# We'll extract the state, need_metric_score, and urgency columns and transform them into JSON.
map_data = df[['state', target, 'urgency']].sort_values(by=target, ascending=False)
map_json = map_data.to_dict(orient='records')

# Save the JSON to a file
with open('map_data.json', 'w') as f:
    json.dump(map_json, f, indent=4)

print("\nJSON data for Google Maps integration:")
print(json.dumps(map_json, indent=4))
